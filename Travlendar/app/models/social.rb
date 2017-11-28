class Social < ApplicationRecord
	has_many :social_users
	has_many :users, through: :social_users
end
