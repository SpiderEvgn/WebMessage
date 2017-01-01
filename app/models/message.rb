class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true

  scope :not_read, ->{ where(is_read: false) }
  scope :to_user, ->(user_id){ where(to_user_id: user_id) }

  # 新的消息创建后发布到对应联系人channel，双方一起更新聊天消息
  # 不会 coffee 的语法，目前只能很笨的在后台拼接 html，将两种显示方式一起发送，前端判断是否是发送者再选择渲染
  after_create_commit { ActionCable.server.broadcast(generate_channel_name(self), 
                                                     messageMy: render_messageMy(self), 
                                                     messageYou: render_messageYou(self),
                                                     receiver: self.to_user_id,
                                                     message_id: self.id
                                                     )
                        ActionCable.server.broadcast("contacts_list_#{self.to_user_id}_channel",
                                                     contact_id: self.user.id,
                                                     new_badge: render_new_badge(self)
                                                     )
                      }
  private

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

  # 更好的方式是 broadcast 只是传送一个信号，由前端完成对未读消息的自加操作（不知道coffee如何实现，有空研究），这样就避免了多余的读取数据库和计算
  def render_new_badge(message)
    new_count = message.user.messages.where(to_user_id: message.to_user_id).not_read.count
    "<span class='badge' id='badge_#{message.user.id}'>#{new_count}</span>"
  end

end
