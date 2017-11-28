class User < ApplicationRecord
	has_many :group_users
	has_many :groups, through: :group_users
	has_many :social_users
	has_many :socials, through: :social_users
	has_many :emails
	has_many :breaks
	has_many :statuses
	has_many :contacts
	has_many :users, through: :contacts
	has_one :email
end
