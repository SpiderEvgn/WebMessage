class UpdateMessageJob < ApplicationJob
	queue_as :default
  
  def perform(message)
  	ActionCable.server.broadcast(generate_channel_name(message), 
                                 messageMy:  render_messageMy(message), 
                                 messageYou: render_messageYou(message),
                                 receiver:   message.to_user_id,
                                 message_id: message.id
                                 )
  end

  private

  # 拼装显示在聊天界面的新弹出消息
  def render_messageMy(message)
    MessagesController.render partial: 'messages/messageMy', locals: { m: message }
  end

  def render_messageYou(message)
    MessagesController.render partial: 'messages/messageYou', locals: { m: message }
  end
  
end