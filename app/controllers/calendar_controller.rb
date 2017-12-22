class CalendarController < ApplicationController
  def show_day
    @user = current_user

    params.require(%i[day month year])
    day = validate_between(params[:day], 1, 31)
    month = validate_between(params[:month], 1, 12)
    year = validate_between(params[:year], 2000, 2100)

    begin
      from_date = DateTime.new(year, month, day)
    rescue ArgumentError
      raise ActionController::RoutingError, 'Not Found'
    end
    to_date = from_date + 1.days

    @schedule = get_schedule(from_date, to_date, @user)

    day_before = from_date - 1.days
    links = {
      day: '',
      week: Rails.application.routes.url_helpers.calendar_week_path(year, from_date.cweek),
      month: Rails.application.routes.url_helpers.calendar_month_path(year, month),
      prev: Rails.application.routes.url_helpers.calendar_day_path(day_before.year, day_before.month, day_before.day),
      next: Rails.application.routes.url_helpers.calendar_day_path(to_date.year, to_date.month, to_date.day)
    }

    prev_text = day_before.strftime '%d %b %Y'
    next_text = to_date.strftime '%d %b %Y'
    render 'calendar/main', locals: { links: links, prev_text: prev_text, next_text: next_text, footer_link: 'day' }
   end

  def show_week
    @user = current_user

    params.require(%i[week year])
    week = validate_between(params[:week], 1, 53)
    year = validate_between(params[:year], 2000, 2100)

    from_date = DateTime.commercial(year, week)
    to_date = from_date + 1.weeks

    @schedule = get_schedule(from_date, to_date, @user)

    # Week number according to the ISO-8601 standard, weeks starting on Monday.
    # The first week of the year is the week that contains that year's first Thursday (='First 4-day week').
    prev_week = from_date - 4.days
    next_week = from_date + 10.days
    links = {
      day: Rails.application.routes.url_helpers.calendar_day_path(year, from_date.month, from_date.day),
      week: '',
      month: Rails.application.routes.url_helpers.calendar_month_path(year, from_date.month),
      prev: Rails.application.routes.url_helpers.calendar_week_path(prev_week.year, prev_week.cweek),
      next: Rails.application.routes.url_helpers.calendar_week_path(next_week.year, next_week.cweek)
    }

    prev_text = (from_date - 1.weeks).strftime '%d %b %Y'
    next_text = (from_date + 1.weeks).strftime '%d %b %Y'
    render 'calendar/main', locals: { links: links, elements_to_skip: [Travel, DefaultLocation, Hash], prev_text: prev_text, next_text: next_text, footer_link: 'week' }
  end

  def show_month
    @user = current_user

    params.require(%i[month year])
    month = validate_between(params[:month], 1, 12)
    year = validate_between(params[:year], 2000, 2100)

    from_date = DateTime.new(year, month)
    to_date = from_date + 1.months

    @schedule = get_schedule(from_date, to_date, @user)

    next_month = from_date + 1.months
    prev_month = from_date - 1.months
    links = {
      day: Rails.application.routes.url_helpers.calendar_day_path(year, month, 1),
      week: Rails.application.routes.url_helpers.calendar_week_path(year, from_date.cweek),
      month: '',
      prev: Rails.application.routes.url_helpers.calendar_month_path(prev_month.year, prev_month.month),
      next: Rails.application.routes.url_helpers.calendar_month_path(next_month.year, next_month.month)
    }

    prev_text = prev_month.strftime '%b %Y'
    next_text = next_month.strftime '%b %Y'
    render 'calendar/main', locals: { links: links, elements_to_skip: [Travel, DefaultLocation, Hash], prev_text: prev_text, next_text: next_text, footer_link: 'month' }
  end

  private

  def get_schedule(from_date, to_date, user)
    schedule = []

    meeting_participations = user.meeting_participations.joins(:meeting)
                                 .where(response_status: MeetingParticipation::Response_statuses[:accepted])
                                 .where(meetings: {start_date: from_date..to_date, end_date: from_date..to_date})
                                 .order('meetings.start_date')
                                 #.where(is_consistent: true)

    current_day = nil
    last_travel_id = -1
    last_default_location_id = -1
    breaks = []

    meeting_participations.each do |mp|
      if current_day.nil? || (mp.meeting.start_date.midnight != current_day)
        # Change the current day
        current_day = mp.meeting.start_date.midnight
        schedule.push current_day
        breaks = user.breaks.where(day_of_the_week: current_day.wday).map do |b|
          computed_break = b.computed_breaks.where(computed_time: current_day..(current_day + 1.days)).first
          if computed_break
            {time: computed_break.computed_time, break: computed_break} if computed_break.is_doable
          else
            {time: current_day + b.default_time.minutes, break: b}
          end
        end
        breaks = breaks.compact.sort_by {|b| b[:time]}
      end

      # If a meeting participation is inconsistent, just push its meeting and forget about travels/default locations
      if mp.is_consistent == false
        push_break_in_schedule schedule, breaks, mp.meeting.start_date
        schedule.push mp.meeting
        next
      end

      if mp.arriving_travel.id != last_travel_id
        push_break_in_schedule schedule, breaks, mp.arriving_travel.start_time
        if (mp.arriving_travel.get_starting_point.is_a?(DefaultLocation) and mp.arriving_travel.get_starting_point.id != last_default_location_id)
          schedule.push mp.arriving_travel.get_starting_point
        end
        schedule.push mp.arriving_travel
      end

      push_break_in_schedule schedule, breaks, mp.meeting.start_date
      schedule.push mp.meeting	# maybe push also response status??
      push_break_in_schedule schedule, breaks, mp.leaving_travel.start_time
      schedule.push mp.leaving_travel

      if(mp.leaving_travel.get_ending_point.is_a?(DefaultLocation))
        schedule.push mp.leaving_travel.get_ending_point
        last_default_location_id = mp.leaving_travel.get_ending_point.id
      end

      last_travel_id = mp.leaving_travel.id
    end

    # If the schedule is still empty just push the from_date and the breaks
    schedule.push from_date.midnight if schedule.empty?

    return schedule
  end

  def push_break_in_schedule(schedule, breaks, time)
    while breaks and breaks.length > 0 and breaks[0][:time] < time do
      schedule.push breaks.pop
    end
  end

  def validate_between(item, lower_bound, upper_bound)
    item = item.to_i
    if (item < lower_bound) || (item > upper_bound)
      raise ActionController::RoutingError, 'Not Found'
      end
    item
  end
end
