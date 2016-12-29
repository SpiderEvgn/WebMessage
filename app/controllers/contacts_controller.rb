class ContactsController < ApplicationController
  before_action :set_contact, only: :destroy

  def index
    contact_ids = current_user.contacts.map(&:contact_id)
    @contact_users = User.find(contact_ids)
  end

  def new
    @contact = current_user.contacts.new
  end

  def create
    case current_user.add_contact(contact_params[:contact_id])
    when "old"
      redirect_to contacts_url, notice: "联系人添加成功（该用户曾经是您的联系人）"
    when "success"
      redirect_to contacts_url, notice: "联系人添加成功。"
    when "not_found"
      flash.now[:alert] = "没有此用户！"
      render :new
    when "taken"
      flash.now[:alert] = "该用户已经是您的联系人。"
      render :new
    end
  end

  def destroy
    @contact.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def set_contact
    @contact = Contact.find_by(user_id: current_user.id, contact_id: params[:id])
  end

  def contact_params
    params.require(:contact).permit(:contact_id)
  end

end
