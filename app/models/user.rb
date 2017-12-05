class User < ApplicationRecord
  has_many :group_users
  has_many :groups, through: :group_users
  has_many :social_users
  has_many :socials, through: :social_users
  has_many :emails
  has_many :breaks
  has_many :statuses

  has_and_belongs_to_many :contacts, class_name: 'User',
                                     join_table: 'contacts',
                                     foreign_key: 'from_user',
                                     association_foreign_key: 'to_user'

  has_many :default_locations
  has_many :meeting_participations
  has_many :constraints

  def primary_email
    Email.find(primary_email_id)
  end

  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  validates :name, :surname, :nickname, :password, :preference_list, presence: true
  validates :nickname, :primary_email_id, uniqueness: true

  validate :primary_email_in_emails

  has_secure_password

  private

  def primary_email_in_emails
    return if primary_email_id.blank?
  end
end
