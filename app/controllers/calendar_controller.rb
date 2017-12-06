class CalendarController < ApplicationController
  	
  	skip_before_action :require_login

  	def show_day
		#@user = current_user
		@user = User.find(1)
  		
  		params.require([:day, :month, :year])
  		day = validate_between(params[:day], 1, 31)
  		month = validate_between(params[:month], 1, 12)
  		year = validate_between(params[:year], 2000, 2100)

  		begin
  			from_date = DateTime.new(year, month, day) 
  		rescue ArgumentError
  			raise ActionController::RoutingError.new('Not Found')
  		end
  		to_date = from_date + 1.days

  		@schedule = get_schedule(from_date, to_date, @user)

  		render 'calendar/day'
  	end

  	def show_week
		#@user = current_user
		@user = User.find(1)

  		params.require([:week, :year])
  		week = validate_between(params[:week], 1, 52)
  		year = validate_between(params[:year], 2000, 2100)
  		
  		first_day_of_year = DateTime.new(year)
  		first_monday_of_year = first_day_of_year + ((8 - first_day_of_year.wday) % 7).days
  		from_date = first_monday_of_year + week.weeks
  		to_date = from_date + 1.weeks

  		@schedule = get_schedule(from_date, to_date, @user)

  		render 'calendar/week'
  	end

  	def show_month
		#@user = current_user
		@user = User.find(1)

  		params.require([:month, :year])
  		month = validate_between(params[:month], 1, 12)
  		year = validate_between(params[:year], 2000, 2100)
  		
  		from_date = DateTime.new(year, month)
  		to_date = from_date + 1.months

  		@schedule = get_schedule(from_date, to_date, @user)

  		render 'calendar/month'
  	end

	private 
	def get_schedule(from_date, to_date, user)
		schedule = []

		/	# Removed for testing
		user.meeting_participations.joins(:meeting).where(meetings:{ start_date: from_date..to_date, end_date: from_date..to_date}).each do |mp|
			schedule.push mp.arriving_travel
			schedule.push mp.meeting 	# maybe push also response status??
			schedule.push mp.leaving_travel
		end/

		# TESTING: grab all meetings
		MeetingParticipation.joins(:meeting).order('meetings.start_date').each do |mp|
			schedule.push mp.arriving_travel
			schedule.push mp.meeting 	# maybe push also response status??
			schedule.push mp.leaving_travel
		end

		return schedule
	end

	def validate_between(item, lower_bound, upper_bound)
		item = item.to_i
		if(item < lower_bound or item > upper_bound)
  			raise ActionController::RoutingError.new('Not Found')
  		end
  		return item
	end
end
