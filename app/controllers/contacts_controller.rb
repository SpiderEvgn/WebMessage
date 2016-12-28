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
    # 先判断在不在历史删除的联系人列表
    contacts_deleted = current_user.contacts.only_deleted
    if contacts_deleted && contacts_deleted.map(&:contact_id).include?(contact_params[:contact_id].to_i)
      d_contact = Contact.only_deleted.find_by(user_id: current_user.id, contact_id: contact_params[:contact_id].to_i)
      Contact.restore(d_contact.id)
      redirect_to contacts_url, notice: "联系人添加成功（该用户曾经是您的联系人）"
    else
      # 判断用户存不存在
      if User.all.map(&:id).include?(contact_params[:contact_id].to_i)
        # 判断是否已经添加到联系人
        if current_user.contacts.map(&:contact_id).include?(contact_params[:contact_id].to_i)
          redirect_to new_contact_path, alert: "该用户已经是您的联系人。"
        else
          @contact = current_user.contacts.new(contact_params)
          @contact.save
          redirect_to contacts_url, notice: "联系人添加成功。"
        end
      else
        # 用 render 会不出现 alert，之后再检查
        redirect_to new_contact_path, alert: "没有此用户！"
      end
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_url, notice: '联系人删除成功。'
  end

  private

  def set_contact
    @contact = Contact.find_by(user_id: current_user.id, contact_id: params[:id])
  end

  def contact_params
    params.require(:contact).permit(:contact_id)
  end

end
