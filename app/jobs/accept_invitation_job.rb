class AcceptInvitationJob < ApplicationJob
  queue_as :default

  def perform(meeting_participation, user)
    MeetingHelper.accept_invitation(meeting_participation, user)
  end
end
