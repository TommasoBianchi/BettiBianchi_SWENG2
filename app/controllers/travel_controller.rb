class TravelController < ApplicationController
  def show
    @travel = Travel.find(params[:id])
    @travel_schedule = []
    @travel_schedule.push(get_starting_point(@travel))

    @travel.travel_steps.each do |t_steps|
      @travel_schedule.push t_steps
    end

    @travel_schedule.push(get_ending_point(@travel))
    @user = @travel.get_user
  end

  private

  def get_starting_point(travel)
    starting_point = MeetingParticipation.find_by(leaving_travel_id: travel.id)
    if starting_point.nil?
      user = travel.get_user
      current_day = travel.start_time
      return user.get_last_default_location_before(current_day)
    else
      return starting_point.meeting
    end
  end

  def get_ending_point(travel)
    ending_point = MeetingParticipation.find_by(arriving_travel_id: travel.id)
    if ending_point.nil?
      user = travel.get_user
      current_day = travel.end_time
      return user.get_last_default_location_before(current_day)
    else
      return ending_point.meeting
    end
  end
end
