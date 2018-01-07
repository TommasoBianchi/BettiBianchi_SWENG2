require 'test_helper'

class MeetingTest < ActiveSupport::TestCase

	test "start and end date consistency" do
		Meeting.all.each do |meeting|
			assert meeting.start_date < meeting.end_date
		end
	end

	test "location must exist" do
		Meeting.all.each do |meeting|
			assert Location.all.include?(meeting.location)
		end
	end

	test "each meeting has at least one participant" do
		Meeting.all.each do |meeting|
			assert meeting.meeting_participations.count > 0
		end
	end

end
