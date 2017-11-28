class SocialUser < ApplicationRecord
	belongs_to :social
	belongs_to :user
end
