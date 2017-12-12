class TravelController < ApplicationController

  before_action :check_my_travel

  def show
    @travel = Travel.find(params[:id])
    @travel_schedule = []
    puts '****************************************'
    @travel_schedule.push(@travel.get_starting_point)
    puts '****************************************'

    @travel.travel_steps.each do |t_steps|
      @travel_schedule.push t_steps
    end

    @travel_schedule.push(@travel.get_ending_point)
    trasform_meeting_participations_in_meeting(@travel_schedule)
    @user = @travel.get_user
  end

  private

  def trasform_meeting_participations_in_meeting(travel_schedule)
    if travel_schedule[0].is_a? MeetingParticipation
      travel_schedule[0] = travel_schedule[0].meeting
    end

    if travel_schedule[-1].is_a? MeetingParticipation
      travel_schedule[-1] = travel_schedule[-1].meeting
    end
  end

  def check_my_travel
    travel = Travel.find(params[:id])
    unless travel.get_starting_point.user_id == current_user.id and travel.get_ending_point.user_id == current_user.id
      raise ActionController::RoutingError, 'Not Found'
    end
  end
end