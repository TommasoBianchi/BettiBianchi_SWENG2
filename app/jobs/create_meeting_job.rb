class CreateMeetingJob < ApplicationJob
  queue_as :default

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
