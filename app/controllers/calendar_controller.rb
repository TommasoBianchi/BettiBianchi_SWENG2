class CalendarController < ApplicationController
	def show
		@user = current_user

		from_date = DateTime.now.midnight
		to_date = DateTime.tomorrow

		@schedule = []
		/.where(meetings:{ start_date: from_date..to_date, end_date: from_date..to_date})/	# Removed for testing
		@user.meeting_participations.joins(:meeting).each do |mp|
			@schedule.push mp.arriving_travel
			@schedule.push mp.meeting 	# maybe push also response status??
			@schedule.push mp.leaving_travel
		end

		render 'calendar/main'
	end
end
