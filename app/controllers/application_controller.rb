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

	private
	def require_login
		unless current_user
			redirect_to homepage_path
		end
	end
end
