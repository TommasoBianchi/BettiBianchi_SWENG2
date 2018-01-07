# This class manages the model(relations, validations and base methods) of the Group object
class Group < ApplicationRecord
	has_many :group_users
	has_many :users, through: :group_users

	validates :name, presence: true
end
