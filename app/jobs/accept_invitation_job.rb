# This class is only used to perform asynchronously the accept_invitation function
class AcceptInvitationJob < ApplicationJob
  queue_as :default

  def perform(meeting_participation, user)
    MeetingHelper.accept_invitation(meeting_participation, user)
  end
end
