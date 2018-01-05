# This class manages the model(relations, validations and base methods) of the GroupUser object
class GroupUser < ApplicationRecord
	belongs_to :group
	belongs_to :user
end
