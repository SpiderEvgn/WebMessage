class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true

  scope :not_read, ->{ where(is_read: false) }
  scope :to_user, ->(user_id){ where(to_user_id: user_id) }

  after_create_commit :sync_update_message, :sync_update_contacts_list
  after_destroy_commit :sync_clear_contact_message, :sync_update_unread_badge

  private

  # 新的消息创建后发布到对应联系人channel，双方一起更新聊天消息
  # 不会 coffee 的语法，目前只能很笨的在后台拼接 html，将两种显示方式一起发送，前端判断是否是发送者再选择渲染
  def sync_update_message
    UpdateMessageJob.perform_later self
  end

  # 发送消息时更新对方联系人列表的对应未读消息数
  # 如果消息发送者不是接受者的联系人，则自动更新接受者的联系人列表
  def sync_update_contacts_list
    UpdateContactsListJob.perform_later self
  end

  # ISSUE: perform_later ?
  # 删除自己消息的同时将对方联系人聊天框中的相应消息清除
  def sync_clear_contact_message
    ClearContactMessageJob.perform_now self
  end

  # 删除信息时，同步更新联系人列表页面的未读消息
  def sync_update_unread_badge
    UpdateUnreadBadgeJob.perform_now self
  end

end
