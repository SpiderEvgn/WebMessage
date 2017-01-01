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
        # 如果自己不是对方联系人好友，则自动添加到对方联系人列表
        @contact_user.add_contact_when_message(current_user.id)
        format.js { head :no_content }
      else
        # bug: 消息为空时的 js 处理有问题，下一个 commit 解决
        format.js { head :no_content }
      end
    end
  end

  def update
    @message.update(is_read: true)
    # respond_to do |format|
    #   if @gmessage.update(is_read: true)
    #     format.html { redirect_to @group, notice: 'Group was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @group }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @group.errors, status: :unprocessable_entity }
    #   end
    # end
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
