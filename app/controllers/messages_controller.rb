class MessagesController < ApplicationController
  before_action :set_contact_id

  def index
    # 获取互相的聊天记录，还未对时间排序
    @messages = []
    current_user.messages.where(to_user_id: params[:contact_id]).each {|m| @messages << m if m}
    @contact.messages.where(to_user_id: current_user.id).each {|m| @messages << m if m}

    @message = current_user.messages.new
  end

  def create
    @message = current_user.messages.build(message_params)
    @message.update_attributes(to_user_id: params[:contact_id])
    @message.save
    redirect_to contact_messages_url(@contact)
  end

  private
  
  def set_contact_id
    @contact = User.find(params[:contact_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

end
