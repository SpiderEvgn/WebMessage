class MessagesController < ApplicationController
  before_action :set_contact_id, only: [:index, :create]
  before_action :set_message, only: :destroy

  def index
    messages_array = []
    current_user.messages.where(to_user_id: params[:contact_id]).each {|m| messages_array << m if m}
    @contact_user.messages.where(to_user_id: current_user.id).each {|m| messages_array << m if m}
    # 将 array 转换成 relation 用于时间排序
    messages_ids = messages_array.map(&:id)
    @messages = Message.includes(:user).where(id: messages_ids).order(:created_at)

    @message = current_user.messages.new
  end

  def create
    @message = current_user.messages.build(message_params)
    @message.update_attributes(to_user_id: params[:contact_id])

    if @message.save
      redirect_to contact_messages_url(@contact_user)
    else
      redirect_to contact_messages_url(@contact_user), alert: "消息不可为空！"
    end
  end

  def destroy
    @message.destroy
    redirect_to contact_messages_url
  end

  private
  
  def set_contact_id
    @contact_user = User.find(params[:contact_id])
  end

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

end
