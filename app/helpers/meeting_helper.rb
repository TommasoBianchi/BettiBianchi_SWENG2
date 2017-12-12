module MeetingHelper

	# start_date and end_date must be valid DateTime objects
	# title must be a non-empty string
	# location must be a valid Location already saved in the db
	# user must be a valid User
	def self.create_meeting(start_date, end_date, title, location, user)
		if start_date >= end_date
			return
		end

		meeting_data = insert_meeting({start_date: start_date, end_date: end_date, location: location}, user)

		meeting = Meeting.create({start_date: start_date, end_date: end_date, title: title, location: location})
		meeting_participation = MeetingParticipation.new
		meeting_participation.meeting = meeting
		meeting_participation.is_admin = true
		meeting_participation.user = user
		meeting_participation.is_consistent = meeting_data[:is_consistent]

		if meeting_data[:is_consistent] == false
			meeting_participation.save 
			meeting_data[:conflict_set].each do |meeting_id|
				# insert in conflict set	
			end
			return
		end

		# From here on we are dealing with only consistent meeting participations

		arriving_travel = Travel.new
		if meeting_data[:link_before_meeting] 
			arriving_travel = meeting_data[:before_meeting].leaving_travel 
		else
			arriving_travel.start_time = meeting_data[:arriving_travel][:start_time]
			arriving_travel.end_time = meeting_data[:arriving_travel][:end_time]
			arriving_travel.travel_mean = meeting_data[:arriving_travel][:travel_mean]
			arriving_travel.distance = meeting_data[:arriving_travel][:distance]
			arriving_travel.starting_location_dl = meeting_data[:arriving_from_dl] if meeting_data[:arriving_from_dl]
			arriving_travel.save
		end 
		leaving_travel = Travel.new
		if meeting_data[:link_after_meeting] 
			leaving_travel = meeting_data[:after_meeting].arriving_travel 
		else
			leaving_travel.start_time = meeting_data[:leaving_travel][:start_time]
			leaving_travel.end_time = meeting_data[:leaving_travel][:end_time]
			leaving_travel.travel_mean = meeting_data[:leaving_travel][:travel_mean]
			leaving_travel.distance = meeting_data[:leaving_travel][:distance]
			leaving_travel.ending_location_dl = meeting_data[:leaving_to_dl] if meeting_data[:leaving_to_dl]
			leaving_travel.save
		end

		meeting_participation.arriving_travel = arriving_travel
		meeting_participation.leaving_travel = leaving_travel
		meeting_participation.response_status = MeetingParticipation::Response_statuses[:accepted]
		meeting_participation.save
	end

	def self.insert_meeting(new_meeting, user)
		user_meetings = user.meeting_participations.joins(:meeting)
		# These are actually MeetingParticipation
		overlapping_meetings = user_meetings.where(meetings: {start_date: new_meeting[:start_date]..new_meeting[:end_date]})
								.or(user_meetings.where(meetings: {end_date: new_meeting[:start_date]..new_meeting[:end_date]}))
		overlapping_meetings.each do |mp|
			mp.is_consistent = false
			new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
			new_meeting[:conflict_set].push mp.meeting_id
		end

		unless overlapping_meetings.empty?
			new_meeting[:is_consistent] = false
			return new_meeting
		end

		defloc_before = user.get_last_default_location_before new_meeting[:start_date]
		defloc_after = user.get_first_location_after new_meeting[:end_date]

		arriving_travel = TravelHelper.best_travel(defloc_before.location, new_meeting[:location], user, nil, new_meeting[:start_date])
		new_meeting[:arriving_from_dl] = defloc_before
		leaving_travel = TravelHelper.best_travel(new_meeting[:location], defloc_after.location, user, new_meeting[:end_date], nil)
		new_meeting[:leaving_to_dl] = defloc_after

		# These are actually MeetingParticipation
		before_meeting = user_meetings.where(is_consistent: true)
						.where('"meetings"."end_date" < ?', new_meeting[:start_date]).order('meetings.end_date').last
		after_meeting = user_meetings.where(is_consistent: true)
						.where('"meetings"."start_date" > ?', new_meeting[:end_date]).order('meetings.start_date').first

		if arriving_travel == nil or (before_meeting != nil and arriving_travel.duration > (new_meeting[:start_date] - before_meeting.leaving_travel.end_time))
			new_meeting[:arriving_from_dl] = nil
			arriving_travel = TravelHelper.best_travel(before_meeting.meeting.location, new_meeting[:location], user, nil, new_meeting[:start_date])
			if arriving_travel == nil or (arriving_travel.duration > (new_meeting[:start_date] - before_meeting.meeting.end_date))
				new_meeting[:is_consistent] = false
				before_meeting.is_consistent = false
				new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
				new_meeting[:conflict_set].push before_meeting.meeting_id
				return new_meeting
			else
				# TODO: link this in a better way (unique travel between two meetings)
			end
		end

		if leaving_travel == nil or (after_meeting != nil and leaving_travel.duration > (after_meeting.arriving_travel.start_time - new_meeting[:end_date]))
			new_meeting[:leaving_to_dl] = nil
			leaving_travel = TravelHelper.best_travel(new_meeting[:location], after_meeting.meeting.location, user, new_meeting[:end_date], nil)
			if leaving_travel == nil or (leaving_travel.duration > (after_meeting.meeting.start_date - new_meeting[:end_date]))
				new_meeting[:is_consistent] = false
				after_meeting.is_consistent = false
				new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
				new_meeting[:conflict_set].push after_meeting.meeting_id
				return new_meeting
			else
				# TODO: link this in a better way (unique travel between two meetings)
			end
		end

		# TODO: manage overlapping breaks and update non-overlapping ones
		/overlapping_breaks := all breaks of user that overlap with new_meeting and its travels

		for all break in overlapping_breaks do
			UPDATE_BREAK(break, new_meeting ,arriving_travel, leaving_travel)
			add (new_meeting, break) to break_overlap_set
		end for/

		new_meeting[:is_consistent] = true
		new_meeting[:arriving_travel] = arriving_travel
		new_meeting[:leaving_travel] = leaving_travel
		return new_meeting
	end
end