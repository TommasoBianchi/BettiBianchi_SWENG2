class SocialUser < ApplicationRecord
	belongs_to :social
	belongs_to :user

	validates :link, presence: true
end
