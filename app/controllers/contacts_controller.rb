class ContactsController < ApplicationController
  before_action :set_contact, only: :destroy

  def index
    contact_ids = current_user.contacts.map(&:contact_id)
    @contacts = User.find(contact_ids)
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
      redirect_to user_contacts_url(current_user.access_token), notice: "New contact added successfully."
    else
      # 判断用户存不存在
      if User.all.map(&:id).include?(contact_params[:contact_id].to_i)
        # 判断是否已经添加到联系人
        if current_user.contacts.map(&:contact_id).include?(contact_params[:contact_id].to_i)
          render :new, notice: "Has already added."
        else
          @contact = current_user.contacts.new(contact_params)
          @contact.save
          redirect_to user_contacts_url(current_user.access_token), notice: "New contact added successfully."\
        end
      else
        render :new, error: "No user found."
      end
    end
  end

  def destroy
    @contact.destroy
    redirect_to user_contacts_url(current_user.access_token), notice: 'Contact was successfully destroyed.'
  end

  private

  def set_contact
    @contact = Contact.find_by(user_id: current_user.id, contact_id: params[:id])
  end

  def contact_params
    params.require(:contact).permit(:contact_id)
  end

end
