class UpdateUnreadBadgeJob < ApplicationJob
  include NewBadgeGenerator
  
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast("contacts_list_#{message.to_user_id}_channel",
                                 status:      "delete",
                                 contact_id:  message.user.id,
                                 new_badge:   render_new_badge(message)
                                 )
  end
end
