class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true

  scope :not_read, ->{ where(is_read: false) }
  scope :to_user, ->(user_id){ where(to_user_id: user_id) }

  # 新的消息创建后发布到对应联系人channel，双方一起更新聊天消息
  after_create_commit { ActionCable.server.broadcast("chat_rooms_room001_channel", message: render_message(self)) }
  private

  # 拼装显示在聊天界面的新弹出消息
  def render_message(message)
    MessagesController.render partial: 'messages/message', locals: { m: message }
  end

end
