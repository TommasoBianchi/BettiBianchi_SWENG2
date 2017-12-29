class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	include HomepageHelper

	before_action :require_login

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

	def get_time_from_integer(integer)
		dt = DateTime.new(2017,1,1,0,0,0) + integer.minutes
		return dt.strftime('%H:%M')
	end

	def isEmail(str)
		reg_ex_pattern = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
		reg_ex_pattern.match?(str)
	end

	private
	def require_login
		unless current_user
			redirect_to homepage_path
		end
	end
end
