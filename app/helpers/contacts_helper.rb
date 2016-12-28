module ContactsHelper
  def not_read_messages(user)
    user.messages.where(to_user_id: current_user.id).not_read.count
  end
end
