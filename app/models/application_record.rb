class ApplicationRecord < ActiveRecord::Base
	self.abstract_class = true

	# This method is used to convert the day of the week from the format in which it is written in the db (integer) to
	# a format that can be easilly read by a user
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

	# This method returns the correct hour format from an integer number that represent minutes after midnight
	def get_time(integer_time_slot)
		if integer_time_slot > 60 * 12
			integer_time_slot = integer_time_slot - 60 * 12
			minutes = integer_time_slot % 60
			minutes = if minutes < 10 then "0#{minutes}" else "#{minutes}" end
			(integer_time_slot / 60).to_s + ":" + minutes + " PM"
		else
			minutes = integer_time_slot % 60
			minutes = if minutes < 10 then "0#{minutes}" else "#{minutes}" end
			(integer_time_slot / 60).to_s + ":" + minutes + " AM"
		end
	end
end
