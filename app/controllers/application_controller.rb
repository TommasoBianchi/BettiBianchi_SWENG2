# This class is the general controller from which all the others inherit
class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	include HomepageHelper

	before_action :require_login, :require_one_default_location


	# This method helps the creators to get a location from the params passed by the user
	def get_location(location_from_input)
		location_input = location_from_input.split(',')
		latitude = location_input[0].to_f
		longitude = location_input[1].to_f
		location_name = location_input[2]
		location = Location.find_by(latitude: latitude, longitude: longitude)

		unless location
			location = Location.create(latitude: latitude, longitude: longitude, description: location_name)
		end
		return location
	end

	# This method is used by the controllers to retrieve the right day index from the day name
	def get_day_by_name(day_of_the_week)
		case day_of_the_week
			when "Sunday"
				0
			when "Monday"
				1
			when "Tuesday"
				2
			when "Wednesday"
				3
			when "Thursday"
				4
			when "Friday"
				5
			when "Saturday"
				6
			else
				'no day'
		end
	end

	# This method is used from the views in order to retrieve the right name to display form the index of the day
	def get_name_of_wday(day_of_the_week)
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
				'no day'
		end
	end

	# This method is used to retrieve the correct time from an integer time (minutes from midnight)
	def get_time_from_integer(integer)
		dt = DateTime.new(2017,1,1,0,0,0) + integer.minutes
		return dt.strftime('%H:%M')
	end

	# This method checks if the string passed is a valid email
	def isEmail(str)
		reg_ex_pattern = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
		reg_ex_pattern.match?(str)
	end

	private

	# This method causes the user to return to the home page if it has not logged in.
	def require_login
		unless current_user
			redirect_to homepage_path
		end
	end

	# This method check if the user has at least one default location and, if not, sends it back to the create first default location page
	def require_one_default_location
		return unless current_user

		if current_user.default_locations.count == 0
			redirect_to create_first_def_location_path current_user.id
		end
	end
end
