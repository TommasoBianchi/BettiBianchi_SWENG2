# This class manages the show page of a travel; everything related with the creation of a travel
# is managed by the travel helper
class TravelController < ApplicationController
	before_action :check_my_travel

	# This method supports the show travel page
	def show
		@travel = Travel.find(params[:id])
		@travel_schedule = []
		@travel_schedule.push(@travel.get_starting_point)

		@travel.travel_steps.each do |t_steps|
			@travel_schedule.push t_steps
		end

		@travel_schedule.push(@travel.get_ending_point)
		trasform_meeting_participations_in_meeting(@travel_schedule)
		@user = @travel.get_user
	end

	private

	# This method trasform the meeting participations in meeting in order to display them properly
	def trasform_meeting_participations_in_meeting(travel_schedule)
		if travel_schedule[0].is_a? MeetingParticipation
			travel_schedule[0] = travel_schedule[0].meeting
		end

		if travel_schedule[-1].is_a? MeetingParticipation
			travel_schedule[-1] = travel_schedule[-1].meeting
		end
	end

	# This method checks if the travel is mine
	def check_my_travel
		travel = Travel.find(params[:id])
		unless travel.get_starting_point.user_id == current_user.id and travel.get_ending_point.user_id == current_user.id
			raise ActionController::RoutingError, 'Not Found'
		end
	end
end
