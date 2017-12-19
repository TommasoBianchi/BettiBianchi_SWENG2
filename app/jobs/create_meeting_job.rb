class CreateMeetingJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, title, location, user)
    MeetingHelper.create_meeting(Time.at(start_date), Time.at(end_date), title, location, user)
  end
end
