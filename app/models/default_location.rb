class DefaultLocation < ApplicationRecord
	belongs_to :user
	belongs_to :location

	validates :starting_hour, :day_of_the_week, :name, presence: true

	validate :day_of_the_week_correctness

	private
	def day_of_the_week_correctness
		if day_of_the_week.blank?
			return
		end
		if day_of_the_week < 0 or day_of_the_week > 6
			errors.add(:day_of_the_week, 'must be before 0 and 6')
		end
	end
end
