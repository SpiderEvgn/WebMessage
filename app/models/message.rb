class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true

  scope :not_read, ->{ where(is_read: false) }
  scope :to_user, ->(user_id){ where(to_user_id: user_id) }

  # 新的消息创建后发布到对应联系人channel，双方一起更新聊天消息
  after_create_commit { ActionCable.server.broadcast(generate_channel_name(self), 
                                                     messageMy: render_messageMy(self), 
                                                     messageYou: render_messageYou(self),
                                                     receiver: self.to_user_id
                                                     ) }
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

end
