# This class manages the model(relations, validations and base methods) of the SocialUser object
class SocialUser < ApplicationRecord
	belongs_to :social
	belongs_to :user

	validates :link, presence: true
end
