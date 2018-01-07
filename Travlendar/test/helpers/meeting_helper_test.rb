class MeetingHelperTest < ActionView::TestCase

	test "create_meeting and invite_to_meeting work properly" do
		# Create a meeting
		start_date = DateTime.new(2020, 1, 1, 12)
		end_date = start_date + 3.hours
		title = "A New Meeting"
		abstract = "This is a new meeting created to test the meeting helper"
		location = Location.last
		user = User.last
		
		result = MeetingHelper.create_meeting start_date, end_date, title, abstract, location, user
		assert (result[:status] != :errors)
		meeting = result[:meeting]
		meeting_participation = result[:meeting_participation]

		assert (meeting.start_date == start_date)
		assert (meeting.end_date == end_date)
		assert (meeting.title == title)
		assert (meeting.abstract == abstract)
		assert (meeting.location == location)
		assert (meeting_participation.meeting == meeting)
		assert (meeting_participation.user == user)
		if result[:status] == :consistent
		 	assert meeting_participation.is_consistent
		else
			assert !meeting_participation.is_consistent
		end 

		# Invite users to the meeting
		User.where.not(id: user.id).each do |invited_user|
			result = MeetingHelper.invite_to_meeting meeting, invited_user
			assert (result[:status] != :errors)
			meeting_participation = result[:meeting_participation]

			assert (meeting_participation.meeting == meeting)
			assert (meeting_participation.user == invited_user)
			if result[:status] == :consistent
			 	assert meeting_participation.is_consistent
			else
				assert !meeting_participation.is_consistent
			end 
		end
	end

end