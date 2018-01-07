# This class is only used to perform asynchronously the MeetingHelper@create_meeting function
class CreateMeetingJob < ApplicationJob
  queue_as :default

  # See the documentation for MeetingHelper@create_meeting
  #
  # Note: after creating the meeting it also enques as many InviteToMeetingJob job as user ids in the invited_user array
  def perform(start_date, end_date, title, abstract, location, user, invited_users = [])
    result = MeetingHelper.create_meeting(Time.at(start_date), Time.at(end_date), title, abstract, location, user)

    if result[:status] == :errors
    	Rails.logger.fatal "Error in creating meeting with parameters #{Time.at(start_date)}, #{Time.at(end_date)},
    							#{title}, #{abstract}, #{location}, #{user}"
		return
    end

    invited_users.each do |user|
    	InviteToMeetingJob.perform_later(result[:meeting], user)
    end
  end
end
