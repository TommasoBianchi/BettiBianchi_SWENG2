class TravelStep < ApplicationRecord
  belongs_to :travel

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
		unless Travel::Travel_means.values.include? travel_mean
			errors.add(:travel_mean, "must be one between #{Travel::Travel_means.values}")
		end
	end
end
