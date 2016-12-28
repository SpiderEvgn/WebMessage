class MessagesController < ApplicationController
  before_action :set_contact_id

  def index
    messages_array = []
    current_user.messages.where(to_user_id: params[:contact_id]).each {|m| messages_array << m if m}
    @contact.messages.where(to_user_id: current_user.id).each {|m| messages_array << m if m}
    # array -> relation for order
    messages_ids = messages_array.map(&:id)
    @messages = Message.includes(:user).where(id: messages_ids).order(:created_at)

    @message = current_user.messages.new
  end

  def create
    @message = current_user.messages.build(message_params)
    @message.update_attributes(to_user_id: params[:contact_id])

    if @message.save
      redirect_to contact_messages_url(@contact)
    # 保存失败的情况还有问题，继续调试
    else
      debugger
      render :index, alert: "消息不可为空！"
    end
  end

  private
  
  def set_contact_id
    @contact = User.find(params[:contact_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

end
