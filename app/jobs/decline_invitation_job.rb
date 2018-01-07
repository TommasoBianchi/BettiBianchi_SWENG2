# This class is only used to perform asynchronously the MeetingHelper@decline_invitation function
class DeclineInvitationJob < ApplicationJob
  queue_as :default

  # See the documentation for MeetingHelper@decline_invitation
  def perform(meeting_participation, user)
    MeetingHelper.decline_invitation(meeting_participation, user)
  end
end
