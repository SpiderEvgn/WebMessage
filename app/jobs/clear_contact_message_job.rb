class ClearContactMessageJob < ApplicationJob
	include ChannelRoomGenerator

  queue_as :default

  def perform(message)
    ActionCable.server.broadcast(generate_channel_name(message), 
                                 status:     "delete",
                                 message_id: message.id
                                 )
  end
end
