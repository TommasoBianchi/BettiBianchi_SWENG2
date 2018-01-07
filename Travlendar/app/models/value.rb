# This class manages the model(relations, validations and base methods) of the Value object
class Value < ApplicationRecord
	belongs_to :subject
	has_many :constraints

	validates :value, presence: true
end
