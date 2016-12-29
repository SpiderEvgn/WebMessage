class User < ApplicationRecord
  attr_accessor :login
  acts_as_paranoid
  has_many :messages
  has_many :contacts, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  validates :username, presence: true, uniqueness: true, length: { in: 6..20 }
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true


  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end

  def add_contact(contact_params)
    # 判断是否存在这个联系人账户
    if contact_params.include? '@'
      contact_user = User.find_by(email: contact_params)
      unless contact_user
        return "not_found"
      end
      contact_id = contact_user.id
    elsif contact_params.length < 6
      contact_id = contact_params.to_i
      unless User.all.map(&:id).include?(contact_id)
        return "not_found"
      end
    else
      contact_user = User.find_by(username: contact_params)
      unless contact_user
        return "not_found"
      end
      contact_id = contact_user.id
    end
    # 判断是否是历史联系人
    contacts_deleted = self.contacts.only_deleted
    if contacts_deleted && contacts_deleted.map(&:contact_id).include?(contact_id)
      d_contact = Contact.only_deleted.find_by(user_id: self.id, contact_id: contact_id)
      Contact.restore(d_contact.id)
      return "old"
    # 判断是否已经添加到联系人
    elsif self.contacts.map(&:contact_id).include?(contact_id)
      return "taken"
    else
      @contact = self.contacts.new(contact_id: contact_id)
      @contact.save
      return "success"
    end
  end

  def add_contact_when_message(contact_id)
    # 判断自己是否是对方联系人的好友，若否，则自动将自己添加到对方联系人列表
    unless self.contacts.map(&:contact_id).include?(contact_id)
      # 先判断自己是否曾经是对方的好友
      contacts_deleted = self.contacts.only_deleted
      if contacts_deleted && contacts_deleted.map(&:contact_id).include?(contact_id)
        d_contact = Contact.only_deleted.find_by(user_id: self.id, contact_id: contact_id)
        Contact.restore(d_contact.id)
      else
        self.contacts.create!(contact_id: contact_id)
      end
    end
  end

  # 获取当前用户与联系人聊天记录
  def get_all_messages(contact_user, count=nil)
    self_messages = self.messages.where(to_user_id: contact_user.id)
    cont_messages = contact_user.messages.where(to_user_id: self.id)
    if count
      self_messages = self_messages.last(5)
      cont_messages = cont_messages.last(5)
    end
    messages_array = []
    self_messages.each {|m| messages_array << m if m}
    cont_messages.each {|m| messages_array << m if m}
    # 将 array 转换成 relation 用于时间排序
    messages_ids = messages_array.map(&:id)
    all_messages = Message.includes(:user).where(id: messages_ids).order(:created_at)
    count ? all_messages.last(5) : all_messages
  end

end
