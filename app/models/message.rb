class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true

  scope :not_read, ->{ where(is_read: false) }
end
