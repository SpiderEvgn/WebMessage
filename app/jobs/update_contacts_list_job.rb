class UpdateContactsListJob < ApplicationJob
  include NewBadgeGenerator

  queue_as :default

  def perform(message)
    ActionCable.server.broadcast("contacts_list_#{message.to_user_id}_channel",
                                 contact_id:  message.user.id,
                                 new_badge:   render_new_badge(message),
                                 new_contact: add_contact_when_message(message)
                                 )
  end

  private

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
      render_new_contact(message)
    else
      return "is_contact"
    end
  end

  # 拼装新加的联系人列表行
  def render_new_contact(message)
    count = message.user.messages.to_user(message.to_user_id).not_read.count
    ContactsController.render partial: 'contacts/newContact', locals: { contact: message.user, count: count }
  end
end
