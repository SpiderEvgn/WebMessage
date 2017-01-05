module ChannelRoomGenerator
  extend ActiveSupport::Concern
  
  private
  
  def generate_channel_name(message)
    user_ids = [message.user.id, message.to_user_id]
    "chat_room_#{user_ids.min}-#{user_ids.max}_channel"
  end

end