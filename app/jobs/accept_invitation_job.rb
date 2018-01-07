# This class is only used to perform asynchronously the MeetingHelper@accept_invitation function
class AcceptInvitationJob < ApplicationJob
  queue_as :default

  # See the documentation for MeetingHelper@accept_invitation
  def perform(meeting_participation, user)
    MeetingHelper.accept_invitation(meeting_participation, user)
  end
end
