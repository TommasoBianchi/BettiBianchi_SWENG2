class ApplicationRecord < ActiveRecord::Base
	self.abstract_class = true

	def get_day_name(day_of_the_week)
		case day_of_the_week
			when 0
				"Sunday"
			when 1
				"Monday"
			when 2
				"Tuesday"
			when 3
				"Wednesday"
			when 4
				"Thursday"
			when 5
				"Friday"
			when 6
				"Saturday"
			else
				"It is not a day of the week!"
		end
	end

	def get_time(integer_time_slot)
		if integer_time_slot > 60 * 12
			integer_time_slot = integer_time_slot - 60 * 12
			(integer_time_slot / 60).to_s + ":" + (integer_time_slot % 60).to_s + " PM"
		else
			(integer_time_slot / 60).to_s + ":" + (integer_time_slot % 60).to_s + " AM"
		end
	end
end
