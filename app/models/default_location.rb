class DefaultLocation < ApplicationRecord
	belongs_to :user
	belongs_to :location

	validates :starting_hour, :day_of_the_week, :name, presence: true

	validate :day_of_the_week_correctness
	validate :no_dl_sharing_start_time

	private

	# This method checks if the day of the week inserted is correct (betweek 0 and 6)
	def day_of_the_week_correctness
		if day_of_the_week.blank?
			return
		end
		if day_of_the_week < 0 or day_of_the_week > 6
			errors.add(:day_of_the_week, 'must be before 0 and 6')
		end
	end

	# This method checks if there isn't any default location that starts in exaclty the same time of the current one
	def no_dl_sharing_start_time
		if user && user.default_locations.where(day_of_the_week: day_of_the_week, starting_hour: starting_hour).count > 0
			errors.add(:starting_hour, 'can not be shared with another default location in the same day')
		end
	end
end
