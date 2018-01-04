class Break < ApplicationRecord
	belongs_to :user

	has_many :computed_breaks

	validates :default_time, :start_time_slot, :end_time_slot, :day_of_the_week, :name, :duration, presence: true

	validate :date_consistency
	validate :day_of_the_week_correctness

	# This method is used bt the views to get the description of a break
	def get_description
		name_of_the_day = get_day_name(day_of_the_week)
		name_of_the_day + ": from " + get_time(start_time_slot) + " to: " + get_time(end_time_slot)
	end
	private

	# This method checks for the date consistency of a break
	def date_consistency
		if [default_time.blank?, start_time_slot.blank?, end_time_slot.blank?].any?
			return
		end
		if default_time < start_time_slot or default_time > end_time_slot
			errors.add(:default_time, 'must be between start_time_slot and end_time_slot')
		end
	end

	# This method checks if the day of the week inserted is correct (between 0 and 6())
	def day_of_the_week_correctness
		if day_of_the_week.blank?
			return
		end
		if day_of_the_week < 0 or day_of_the_week > 6
			errors.add(:day_of_the_week, 'must be before 0 and 6')
		end
	end
end