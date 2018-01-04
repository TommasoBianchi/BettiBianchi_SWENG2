class DefaultLocation < ApplicationRecord
	belongs_to :user
	belongs_to :location

	validates :starting_hour, :day_of_the_week, :name, presence: true

	validate :day_of_the_week_correctness
	validate :no_dl_sharing_start_time

	private
	def day_of_the_week_correctness
		if day_of_the_week.blank?
			return
		end
		if day_of_the_week < 0 or day_of_the_week > 6
			errors.add(:day_of_the_week, 'must be before 0 and 6')
		end
	end

	def no_dl_sharing_start_time
		if user && user.default_locations.where(day_of_the_week: day_of_the_week, starting_hour: starting_hour).count > 0
			errors.add(:starting_hour, 'can not be shared with another default location in the same day')
		end
	end
end
