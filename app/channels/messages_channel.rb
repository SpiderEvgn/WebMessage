# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class MessagesChannel < ApplicationCable::Channel
  # Called when the consumer has successfully become a subscriber of this channel.
  def subscribed
    # 按聊天双方的 user.id “小-大” 的模式建立 channel 的唯一名字
    user_ids = params['chat_user_ids'].split('-').map(&:to_i)
    stream_from "chat_room_#{user_ids.min}-#{user_ids.max}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # def send_message(data)
  #   current_user.messages.create!(body: data['message'], chat_room_id: data['chat_room_id'])
  # end
end
