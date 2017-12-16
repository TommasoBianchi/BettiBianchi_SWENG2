class Constraint < ApplicationRecord

	# This should be a constant
	Travel_means = {
			walking: 0,
			driving: 1,
			public_transportation: 2,
			biking: 3
	}.freeze

	belongs_to :user
	belongs_to :subject
	belongs_to :operator
	belongs_to :value

	validates :travel_mean, presence: true

	def get_description
		travel_mean.to_s + " if " + subject.name + " " + operator.description + " " + value.value
	end
end
