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

    #meeting_participations = user.meeting_participations.joins(:meeting).where(meetings:{ start_date: from_date..to_date, end_date: from_date..to_date})
    # TESTING grab all meetings
    meeting_participations = MeetingParticipation.joins(:meeting).order('meetings.start_date')

    current_day = nil
    last_travel_id = -1

		meeting_participations.each do |mp|
      if current_day == nil or mp.meeting.start_date.midnight != current_day
        # Push the end-day default location before changing day
        schedule.push user.default_locations.
          where(day_of_the_week: current_day.wday)
          .order(:starting_hour).last unless current_day == nil

        # Change the current day
        current_day = mp.meeting.start_date.midnight
        schedule.push current_day
      end

      if(mp.arriving_travel.id != last_travel_id)
        travel_starting_time_from_midnight = (mp.arriving_travel.start_time - mp.arriving_travel.start_time.midnight) / 60
        schedule.push user.default_locations.
          where(day_of_the_week: current_day.wday, starting_hour: 0..travel_starting_time_from_midnight)
          .order(:starting_hour).last
			  schedule.push mp.arriving_travel 
      end
			schedule.push mp.meeting 	# maybe push also response status??
			schedule.push mp.leaving_travel

      last_travel_id = mp.leaving_travel.id
		end

    # Push the end-day default location for the last day
    schedule.push user.default_locations.
      where(day_of_the_week: current_day.wday)
      .order(:starting_hour).last unless current_day == nil

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
