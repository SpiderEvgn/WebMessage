class MessagesController < ApplicationController
  before_action :set_contact_id, only: [:index, :create, :history]
  before_action :set_message, only: :destroy

  def index
    # 聊天框初始只显示最后 5 次记录
    @messages = current_user.get_all_messages(@contact_user, 5)
    # 进入聊天后，将此联系人用户未读消息置否
    @contact_user.clear_messages_unread_count(current_user.id)
    
    @message = current_user.messages.new
  end

  def history
    @messages = current_user.get_all_messages(@contact_user)
  end

  def create
    @message = current_user.messages.build(message_params)
    @message.update_attributes(to_user_id: params[:contact_id])
    if @message.save
      # 如果自己不是对方联系人好友，则自动添加到对方联系人列表
      @contact_user.add_contact_when_message(current_user.id)
      respond_to do |format|
        # format.html { redirect_to contact_messages_url(@contact_user) }
        format.js
      end
    else
      @messages = current_user.get_all_messages(@contact_user, 5)
      # 消息为空时的 js 处理有问题，下一个 commit 解决
      respond_to do |format|
        # format.html { redirect_to contact_messages_url(@contact_user) }
        format.js { render :index }
      end
    end

  end

  def destroy
    @message.destroy
    redirect_to :back
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
