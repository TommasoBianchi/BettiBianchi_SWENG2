class DeclineInvitationJob < ApplicationJob
  queue_as :default

  def perform(meeting_participation, user)
    MeetingHelper.decline_invitation(meeting_participation, user)
  end
end
