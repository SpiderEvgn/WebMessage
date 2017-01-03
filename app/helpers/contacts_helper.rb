module ContactsHelper
  def not_read_messages_count(user)
    user.messages.to_user(current_user.id).not_read.count
  end
end
