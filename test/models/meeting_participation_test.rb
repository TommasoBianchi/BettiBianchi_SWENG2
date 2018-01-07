require 'test_helper'

class MeetingParticipationTest < ActiveSupport::TestCase

	test "user must exist" do
		MeetingParticipation.all.each do |mp|
			assert User.all.include?(mp.user)
		end
	end

	test "meeting must exist" do
		MeetingParticipation.all.each do |mp|
			assert Meeting.all.include?(mp.meeting)
		end
	end

	test "no different mp with the same user and meeting" do
		MeetingParticipation.all.each do |mp|
			assert MeetingParticipation.where(meeting: mp.meeting, user: mp.user).count == 1
		end
	end
end
