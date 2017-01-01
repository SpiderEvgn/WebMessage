# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class MessagesChannel < ApplicationCable::Channel
  # Called when the consumer has successfully become a subscriber of this channel.
  def subscribed
    stream_from "chat_rooms_#{params['chat_room_id']}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # def send_message(data)
  #   current_user.messages.create!(body: data['message'], chat_room_id: data['chat_room_id'])
  # end
end