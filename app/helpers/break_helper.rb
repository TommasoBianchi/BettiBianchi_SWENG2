# This is a helper module containing various functions to recompute flexible breaks in various way
module BreakHelper

	# Update a single break in a given day
	#
	# * b is an ApplicationRecord::Break
	# * day is a DateTime
	def self.update_break(b, day)
		return unless b.day_of_the_week == day.wday

		from = day.midnight + b.start_time_slot.minutes
		to = day.midnight + b.end_time_slot.minutes

		# Grab all the meetings potentially overlapping with the break b
		user_meeting_participations = b.user.meeting_participations.where(is_consistent: true)
										.where(response_status: MeetingParticipation::Response_statuses[:accepted])		
		overlapping_meeting_participations = user_meeting_participations.joins(:meeting).where('meetings.start_date between :start and :end
												or meetings.end_date between :start and :end
												or (meetings.start_date <= :start and meetings.end_date >= :end)', start: from, end: to)

		# Grab all the travels potentially overlapping with the break b
		overlapping_travels = Travel.where('start_time between :start and :end
											or end_time between :start and :end
											or (start_time <= :start and end_time >= :end)', start: from, end: to)
									.select {|travel| travel.get_user == b.user} 

		# Uniform meetings and travels in the form of time intervals
		time_intervals = []
		overlapping_meeting_participations.each do |mp|
			time_intervals.push({from: mp.meeting.start_date, to: mp.meeting.end_date})
		end
		overlapping_travels.each do |t|
			next unless (t.get_starting_point and t.get_ending_point)	# Avoid "zombie" travels
			time_intervals.push({from: t.start_time, to: t.end_time})
		end

		# Call the lower level break update
		_update_break b, day, time_intervals
	end

	# Update all the breaks of a given user between from_date and to_date (they should be the same date at different times)
	#
	# * from_date is a DateTime
	# * to_date is a DateTime
	# * user is an ApplicationRecord::User
	def self.update_all_breaks(from_date, to_date, user)
		# TODO: maybe from_date and to_date are in different wdays. Deal with it

		from = (from_date.utc - from_date.utc.midnight) / 60	# in minutes since midnight
		to = (to_date.utc - to_date.utc.midnight) / 60 # in minutes since midnight
		user_breaks = user.breaks.where(day_of_the_week: from_date.wday)
		overlapping_breaks = user_breaks.where(start_time_slot: from..to)
								.or(user_breaks.where(end_time_slot: from..to))
								.or(user_breaks.where(start_time_slot: 0..from).where(end_time_slot: to..24*60))
		
		overlapping_breaks.each do |b|
			update_break b, from_date
		end
	end

	# Update every occurrence of a given break
	#
	# * b is an ApplicationRecord::Break
	def self.full_update_break(b)
		# Drop all already computed breaks
		ComputedBreak.where(break: b).delete_all

		# Compute the last day in which the user has a meeting participation	
		meeting_participations = b.user.meeting_participations.joins(:meeting).order('meetings.start_date')	
		return if meeting_participations.count == 0
		last_day = meeting_participations.last.meeting.start_date.midnight

		# For each day in the user's schedule from now on recompute the break b
		current_day = DateTime.now.utc.midnight
		while current_day <= last_day do 
			update_break b, current_day

			current_day += 1.days
		end
	end

	private
	def self._update_break(b, day, time_intervals)
		# Fetch the computed break or create one if not present
		cb = ComputedBreak.where(computed_time: day.midnight..(day.midnight + 1.days), break: b).first
		if cb == nil 
			cb = ComputedBreak.create({computed_time: day.midnight + b.default_time.minutes,
									   start_time_slot: day.midnight + b.start_time_slot.minutes,
									   end_time_slot: day.midnight + b.end_time_slot.minutes,
									   user: b.user, break: b, duration: b.duration, name: b.name,
									   is_doable: true
									   })
		end

		# Update the doability bitmask
		doability_bitmask = [1] * (b.end_time_slot - b.start_time_slot)

		time_intervals.each do |interval|	# time is counted in steps of minutes
			from = ((interval[:from].utc - day.utc.midnight) / 60).to_i - b.start_time_slot
			from = 0 if from < 0
			to = ((interval[:to].utc - day.utc.midnight) / 60).to_i - b.start_time_slot
			to = doability_bitmask.length - 1 if to >= doability_bitmask.length
			for i in from..to  do
				doability_bitmask[i] = 0
			end
		end

		# Place the computed break in the available free slot closer to the default time
		default_index = b.default_time - b.start_time_slot
		forward_index = default_index
		backward_index = forward_index - 1
		while (forward_index < doability_bitmask.length or backward_index > 0) do 
			# At each step proceed from the index closest to the default one
			# But be careful if one of the two indices is already out of range
			if (backward_index < 0 or forward_index - default_index < default_index - backward_index) and forward_index < doability_bitmask.length
				slot_count = 0
				for i in forward_index..doability_bitmask.length - 1
					if doability_bitmask[i] == 0 or slot_count >= cb.duration
						break
					else
						slot_count += 1
					end
				end

				if slot_count >= cb.duration
					cb.update(computed_time: cb.start_time_slot + forward_index.minutes, is_doable: true)
					return true
				else
					forward_index = i + 1
				end
			else
				slot_count = 0
				for i in backward_index.downto(0)
					if doability_bitmask[i] == 0 or slot_count >= cb.duration
						break
					else
						slot_count += 1
					end
				end

				if slot_count >= cb.duration
					cb.update(computed_time: cb.start_time_slot + (backward_index - cb.duration).minutes, is_doable: true)
					return true
				else
					backward_index = i - 1
				end
			end
		end
	
		cb.update(is_doable: false)
		return false
	end
end
