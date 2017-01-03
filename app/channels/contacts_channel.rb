# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ContactsChannel < ApplicationCable::Channel
  # Called when the consumer has successfully become a subscriber of this channel.
  def subscribed
    stream_from "contacts_list_#{params['current_user_id']}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
