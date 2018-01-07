require 'test_helper'

class MeetingParticipationConflictTest < ActiveSupport::TestCase

	test "no mp in conflict with itself" do
		assert MeetingParticipationConflict.where("meeting_participation_1_id = meeting_participation_2_id").count == 0
	end

	test "two conflict mp belong to the same user" do
		MeetingParticipationConflict.all.each do |mpc|
			assert mpc.meeting_participation1.user == mpc.meeting_participation2.user
		end
	end

	test "no repeated meeting participation conflicts" do
		MeetingParticipationConflict.all.each do |mpc|
			assert MeetingParticipationConflict.where(meeting_participation1: mpc.meeting_participation2, meeting_participation2: mpc.meeting_participation1).count == 0
		end
	end

end
