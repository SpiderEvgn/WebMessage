class ContactsController < ApplicationController
  before_action :set_user

  def index
    # 此处查询需要优化，用一次请求完成
    @contacts = []
    @user.contacts.each do |contact|
      contact_info = User.find(contact.contact_id)
      @contacts << contact_info
    end
  end

  def new
  end

  def create
  end

  def delete
  end

  private

  def set_user
    @user = User.find_by(access_token: params[:access_token])
  end

  def user_params
    params.require(:user).permit(:id, :user_id, :contact_id)
  end

end
