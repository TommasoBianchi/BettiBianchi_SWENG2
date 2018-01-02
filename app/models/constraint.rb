class Constraint < ApplicationRecord

	# This should be a constant
	Travel_mean_names = {
			walking: 'Walking',
			driving: 'Driving',
			public_transportation: 'Public Transportation',
			biking: 'Biking'
	}.freeze

	belongs_to :user
	belongs_to :subject
	belongs_to :operator
	belongs_to :value

	validates :travel_mean, presence: true

	def get_description
		Travel_mean_names[Travel::Travel_means.keys[travel_mean]] + " if " + subject.name + " " + operator.description + " " + value.value
	end

	def check_path(path)
		lv = subject.get_path_value(path)
		rv = value.value
		if lv.is_a? Integer
			rv = rv.to_i
		elsif lv.is_a? DateTime
			rv = rv.to_datetime
		end
		return operator.invoke lv, rv
	end
end