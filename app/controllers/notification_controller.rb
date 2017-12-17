class NotificationController < ApplicationController
	def index
		@user = current_user
    	@pending_meeting = MeetingParticipation.where('response_status = :response_status AND user_id = :user',
    							response_status: MeetingParticipation::Response_statuses[:pending], user: @user.id)
    	@warning_meeting = @user.meeting_participations.where(is_consistent: false)
    							.where.not(response_status: MeetingParticipation::Response_statuses[:declined])
	end
end
