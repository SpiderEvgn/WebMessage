class MessagesController < ApplicationController
  before_action :set_contact_id

  def index
    @messages = []
    current_user.messages.where(to_user_id: params[:to_user_id]).each {|m| @messages << m if m}
    @contact.messages.where(to_user_id: current_user.id).each {|m| @messages << m if m}

    @message = current_user.messages.new
  end

  def create
    @message = current_user.messages.build(message_params)
    @message.update_attributes(to_user_id: params[:to_user_id])
    @message.save
    redirect_to user_contact_messages_url(current_user.access_token, @contact)
  end

  private
  
  def set_contact_id
    @contact = User.find(params[:to_user_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

end
