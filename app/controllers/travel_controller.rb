class TravelController < ApplicationController
  def show
    @travel = Travel.find(params[:id])
    @travel_schedule = []
    @travel_schedule.push(get_starting_point(@travel))

    @travel.travel_steps.each do |t_steps|
      @travel_schedule.push t_steps
    end

    @travel_schedule.push(get_ending_point(@travel))
    @user = get_user(@travel)
  end

  private

  def get_starting_point(travel)
    starting_point = MeetingParticipation.find_by(leaving_travel_id: travel.id)
    if starting_point.nil?
      mp_of_travel = MeetingParticipation.find_by(arriving_travel_id: travel.id)
      user = mp_of_travel.user
      current_day = travel.start_time
      return user.get_last_default_location_after(current_day)
    else
      puts '****************************************'
      puts '****************************************'
      puts '****************************************'
      return starting_point.meeting
    end
  end

  def get_ending_point(travel)
    ending_point = MeetingParticipation.find_by(arriving_travel_id: travel.id)
    if ending_point.nil?
      user = mp_of_travel.user
      current_day = travel.end_time
      return user.get_first_location_after(current_day)
    else
      return ending_point.meeting
    end
  end

  def get_user(travel)
    mp1 = MeetingParticipation.find_by(arriving_travel_id: travel.id)
    if mp1.nil?
      return MeetingParticipation.find_by(arriving_travel_id: travel.id).user
    else
      return mp1.user
    end
  end
end
