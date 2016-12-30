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

  # issue: 需要考虑username的大小写问题，devise默认登录方法是忽略大小写，但是创建时不同于devise默认字段email用小写保存，
  # 导致在用username添加联系人时会因为大小写混乱（忽略大小写可以登录，但是添加联系人要求严格大小写）目前设置了username
  # 的唯一性验证也是忽略大小写的，所以暂时没有逻辑漏洞
  validates :username, presence: true, uniqueness: true, length: { in: 6..20 }
  validates_format_of :username, with: /^[a-z0-9_\.]*$/, :multiline => true


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
      contact_user = User.find_by(email: contact_params.downcase)
      unless contact_user
        return { status: "not_found" }
      end
      contact_user_id = contact_user.id
    elsif contact_params.length > 5
      contact_user = User.find_by(username: contact_params)
      unless contact_user
        return { status: "not_found" }
      end
      contact_user_id = contact_user.id
    else
      return { status: "not_found" }
    end
    # 判断是否是历史联系人
    contacts_deleted = self.contacts.only_deleted
    if contacts_deleted && contacts_deleted.map(&:contact_id).include?(contact_user_id)
      d_contact = Contact.only_deleted.find_by(user_id: self.id, contact_id: contact_user_id)
      # issue: 这里还要处理一个逻辑，将 updated_at 置为 now，联系人的添加时间要现实 updated_at
      Contact.restore(d_contact.id)
      return {
        status: "old",
        contact_user_id: contact_user_id
        }
    # 判断是否已经添加到联系人
    elsif self.contacts.map(&:contact_id).include?(contact_user_id)
      return { status: "taken" }
    else
      @contact = self.contacts.new(contact_id: contact_user_id)
      @contact.save
      {
        status: "success",
        contact_user_id: contact_user_id
      }
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
    self_messages = self.messages.to_user(contact_user.id)
    cont_messages = contact_user.messages.to_user(self.id)
    if count
      self_messages = self_messages.last(10)
      cont_messages = cont_messages.last(10)
    end
    messages_array = []
    self_messages.each {|m| messages_array << m if m}
    cont_messages.each {|m| messages_array << m if m}
    # 将 array 转换成 relation 用于时间排序
    messages_ids = messages_array.map(&:id)
    all_messages = Message.includes(:user).where(id: messages_ids).order(:created_at)
    count ? all_messages.last(10) : all_messages
  end

  # 将联系人用户未读消息置否
  def clear_messages_unread_count(current_user_id)
    self.messages.to_user(current_user_id).not_read.update_all(is_read: true)
  end

end
