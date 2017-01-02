module ContactsHelper
  def not_read_messages_count(user)
    user.messages.where(to_user_id: current_user.id).not_read.count
  end
end
