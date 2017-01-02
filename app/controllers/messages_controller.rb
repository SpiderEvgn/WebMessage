class MessagesController < ApplicationController
  before_action :set_contact_user, only: [:index, :create, :history]
  before_action :set_message, only: [:destroy, :update]

  def index
    # 聊天框初始只显示最后 10 次记录
    @messages = current_user.get_all_messages(@contact_user, 5)
    # 进入聊天后，将此联系人用户未读消息置否
    @contact_user.clear_messages_unread_count(current_user.id)
    
    @message = current_user.messages.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def history
    @messages = current_user.get_all_messages(@contact_user)
  end

  def create
    @message = current_user.messages.build(message_params)
    @message.update_attributes(to_user_id: params[:contact_id])
    respond_to do |format|
      if @message.save
        # 保存成功的话，就执行 after_create_commit，不返回任何内容，交由actioncable处理
        format.js { head :no_content }
      else
        # TODO: 消息为空时的处理有点丑，暂且如此，先去处理别的优先级高的功能
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      @message.update(is_read: true)
      format.js { head :no_content }
    end
  end

  def destroy
    @message.destroy
    respond_to do |format|
      format.js
    end
  end

  private
  
  def set_contact_user
    @contact_user = User.find(params[:contact_id])
  end

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

end
