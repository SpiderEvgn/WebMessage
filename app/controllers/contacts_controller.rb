class ContactsController < ApplicationController
  before_action :set_contact, only: :destroy

  def index
    contact_ids = current_user.contacts.map(&:contact_id)
    @contact_users = User.find(contact_ids)
  end

  def create
    result = current_user.add_contact(contact_params[:contact_id])
    if result[:status] == "old" || result[:status] == "success"
      @new_contact = User.find(result[:contact_user_id])
    end
    respond_to do |format|
      format.js
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
