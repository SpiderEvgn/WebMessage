class MessagesController < ApplicationController
  before_action :set_contact_id, only: [:index, :create, :history]
  before_action :set_message, only: :destroy

  def index
    messages_array = []
    current_user.messages.where(to_user_id: params[:contact_id]).last(5).each {|m| messages_array << m if m}
    @contact_user.messages.where(to_user_id: current_user.id).last(5).each {|m| messages_array << m if m}
    # 将 array 转换成 relation 用于时间排序
    messages_ids = messages_array.map(&:id)
    @messages = Message.includes(:user).where(id: messages_ids).order(:created_at).last(5)

    # 进入聊天后，将此联系人用户所有消息设为已读，之后优化只更新未读条目
    @contact_user.messages.where(to_user_id: current_user).update_all(is_read: true)

    @message = current_user.messages.new
  end

  def history
    messages_array = []
    current_user.messages.where(to_user_id: params[:contact_id]).each {|m| messages_array << m if m}
    @contact_user.messages.where(to_user_id: current_user.id).each {|m| messages_array << m if m}
    messages_ids = messages_array.map(&:id)
    @messages = Message.includes(:user).where(id: messages_ids).order(:created_at)
  end

  def create
    @message = current_user.messages.build(message_params)
    @message.update_attributes(to_user_id: params[:contact_id])

    if @message.save
      # 判断自己是否是对方联系人的好友，若否，则自动将自己添加到对方联系人列表
      unless @contact_user.contacts.map(&:contact_id).include?(current_user.id)
        # 先判断自己是否曾经是对方的好友
        contacts_deleted = @contact_user.contacts.only_deleted
        if contacts_deleted && contacts_deleted.map(&:contact_id).include?(current_user.id)
          d_contact = Contact.only_deleted.find_by(user_id: @contact_user.id, contact_id: current_user.id)
          Contact.restore(d_contact.id)
        else
          @contact_user.contacts.create!(contact_id: current_user.id)
        end
      end
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
