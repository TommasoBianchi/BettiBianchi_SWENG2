class Email < ApplicationRecord
  belongs_to :user

  validates :email, presence: true, uniqueness: true

  before_save do
    self.email = email.downcase
  end
end
