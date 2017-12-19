class CreateMeetingJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, title, abstract, location, user, invited_users = [])
    meeting = MeetingHelper.create_meeting(Time.at(start_date), Time.at(end_date), title, abstract, location, user)

    invited_users.each do |user|
    	InviteToMeetingJob.perform_later(meeting, user)
    end
  end
end
