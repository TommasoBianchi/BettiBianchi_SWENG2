class NotificationController < ApplicationController
	def index
		@user = current_user
    	@pending_meeting = MeetingParticipation.where('response_status = :response_status AND user_id = :user', response_status: 0, user: @user.id)
    	@warning_meeting = MeetingParticipation.where(is_consistent: false)
	end
end
