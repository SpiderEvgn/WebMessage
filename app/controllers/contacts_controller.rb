class ContactsController < ApplicationController
  before_action :set_user

  def index
    # 此处查询需要优化，用一次请求完成
    contact_ids = @user.contacts.map(&:contact_id)
    @contacts = User.find(contact_ids)
  end

  def new
    @contact = @user.contacts.new
  end

  def create
    # 先判断在不在历史删除的联系人列表
    debugger
    contacts_deleted = @user.contacts.only_deleted
    if contacts_deleted && contacts_deleted.map(&:contact_id).include?(contact_params[:contact_id].to_i)
      Contact.restore(contact_params[:contact_id].to_i)
      redirect_to user_contacts_url(@user.access_token), notice: "New contact added successfully."
    else
      if User.all.map(&:id).include?(contact_params[:contact_id].to_i)
        @contact = @user.contacts.new(contact_params)
        @contact.save
        redirect_to user_contacts_url(@user.access_token), notice: "New contact added successfully."
      else
        render :new, error: "No user found."
      end
    end
  end

  def delete
  end

  private

  def set_user
    @user = User.find_by(access_token: params[:access_token])
  end

  def contact_params
    params.require(:contact).permit(:contact_id)
  end

end
