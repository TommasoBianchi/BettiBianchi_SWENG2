class Travel < ApplicationRecord
	# This should be a constant
	Travel_means = {
		walking: 0,
		driving: 1,
		public_transportation: 2,
		biking: 3
	}

	belongs_to :meeting_participation
	has_many :travel_steps

	validates :start_time, :end_time, :distance, :travel_mean, presence: true

	validate :date_consistency
	validate :travel_mean_correctness

	private
	def date_consistency
		if [start_time.blank?, end_time.blank?].any?
			return
		end
		if start_time > end_time
			errors.add(:start_time, 'must be after end_time')
		end
	end

	def travel_mean_correctness
		if travel_mean.blank?
			return
		end
		unless Travel_means.values.include? travel_mean
			errors.add(:travel_mean, "must be one between #{Travel_means.values}")
		end
	end
end
