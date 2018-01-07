# This class is only used to perform asynchronously the MeetingHelper@invite_to_meeting function
class InviteToMeetingJob < ApplicationJob
  queue_as :default

  # See the documentation for MeetingHelper@invite_to_meeting
  def perform(meeting, user)
    MeetingHelper.invite_to_meeting(meeting, user)
  end
end
