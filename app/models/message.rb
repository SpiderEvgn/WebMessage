class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true

  scope :not_read, ->{ where(is_read: false) }
  scope :to_user, ->(user_id){ where(to_user_id: user_id) }

  after_create_commit :sync_update_message, :sync_update_contacts_list
  after_destroy_commit :sync_clear_contact_message   
                   
  private

  # 新的消息创建后发布到对应联系人channel，双方一起更新聊天消息
  # 不会 coffee 的语法，目前只能很笨的在后台拼接 html，将两种显示方式一起发送，前端判断是否是发送者再选择渲染
  def sync_update_message
    ActionCable.server.broadcast(generate_channel_name(self), 
                                 messageMy:  render_messageMy(self), 
                                 messageYou: render_messageYou(self),
                                 receiver:   self.to_user_id,
                                 message_id: self.id
                                 )
  end

  # 删除自己消息的同时将对方联系人聊天框中的相应消息清除
  def sync_clear_contact_message
    ActionCable.server.broadcast(generate_channel_name(self), 
                                 status:       "delete",
                                 clearMessage: "$('#message_#{self.id}').fadeOut()"
                                 )
  end

  # 发送消息时更新对方联系人列表的对应未读消息数
  # 如果消息发送者不是接受者的联系人，则自动更新接受者的联系人列表
  def sync_udpate_contacts_list
    ActionCable.server.broadcast("contacts_list_#{self.to_user_id}_channel",
                                 contact_id:  self.user.id,
                                 new_badge:   render_new_badge(self),
                                 new_contact: add_contact_when_message(self)
                                 )
  end
  # 拼装聊天 channel 的名字
  def generate_channel_name(message)
  	user_ids = [message.user.id, message.to_user_id]
    "chat_room_#{user_ids.min}-#{user_ids.max}_channel"
  end

  # 拼装显示在聊天界面的新弹出消息
  def render_messageMy(message)
    MessagesController.render partial: 'messages/messageMy', locals: { m: message }
  end

  def render_messageYou(message)
    MessagesController.render partial: 'messages/messageYou', locals: { m: message }
  end

  # 更好的方式是 broadcast 只是传送一个信号，由前端完成对未读消息的自加操作（不知道coffee如何实现，有空研究），这样就避免了多余的数据库读取和计算
  def render_new_badge(message)
    new_count = message.user.messages.where(to_user_id: message.to_user_id).not_read.count
    "<span class='badge' id='badge_#{message.user.id}' style='color:red'>#{new_count}</span>"
  end

  # 如果消息发送者不是接受者的联系人，则自动更新接受者的联系人列表
  def add_contact_when_message(message)
    receiver = User.find(message.to_user_id)
    # 判断自己是否是对方联系人的好友，若否，则自动将自己添加到对方联系人列表
    unless receiver.contacts.map(&:contact_id).include?(message.user.id)
      # 先判断自己是否 曾经 是对方的好友
      contacts_deleted = receiver.contacts.only_deleted
      if contacts_deleted && contacts_deleted.map(&:contact_id).include?(message.user.id)
        d_contact = Contact.only_deleted.find_by(user_id: receiver.id, contact_id: message.user.id)
        Contact.restore(d_contact.id)
      else
        receiver.contacts.create!(contact_id: message.user.id)
      end
      render_new_contact(message.user)
    else
      return "is_contact"
    end
  end

  # 拼装新加的联系人列表行
  def render_new_contact(contact)
    ContactsController.render partial: 'contacts/newContact', locals: { contact: contact }
  end

end
