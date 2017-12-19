class InviteToMeetingJob < ApplicationJob
  queue_as :default

  def perform(meeting, user)
    MeetingHelper.invite_to_meeting(meeting, user)
  end
end
