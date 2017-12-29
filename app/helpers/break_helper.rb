module BreakHelper

	def self.update_break(b, day)
		from = day.midnight + b.start_time_slot.minutes
		to = day.midnight + b.end_time_slot.minutes
		user_meeting_participations = b.user.meeting_participations.where(is_consistent: true)
										.where(response_status: MeetingParticipation::Response_statuses[:accepted])
		# TODO: joins also with travel to get overlapping mps also wrt them
		overlapping_meeting_participations = user_meeting_participations.joins(:meeting).where('meetings.start_date between :start and :end
												or meetings.end_date between :start and :end
												or (meetings.start_date <= :start and meetings.end_date >= :end)', start: from, end: to)

		time_intervals = []
		overlapping_meeting_participations.each do |mp|
			time_intervals.push({from: mp.arriving_travel.start_time, to: mp.arriving_travel.end_time})
			time_intervals.push({from: mp.meeting.start_date, to: mp.meeting.end_date})
			time_intervals.push({from: mp.leaving_travel.start_time, to: mp.leaving_travel.end_time})
		end

		_update_break b, day, time_intervals
	end

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

	def self.full_update_break(b)
		# Drop all already computed breaks
		ComputedBreak.where(break: b).delete_all

		# Compute the last day in which the user has a meeting participation		
		last_day = b.user.meeting_participations.joins(:meeting).order('meetings.start_date').last.meeting.start_date.midnight

		# For each day in the user's schedule from now on recompute the break b
		current_day = DateTime.now.midnight
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

=begin
		# Place the computed break in the first available free slot
		i = 0
		while i < doability_bitmask.length do
			if doability_bitmask[i] == 0
				i += 1
				next
			end

			slot_count = 0
			for j in i..doability_bitmask.length - 1
				if doability_bitmask[j] == 1
					break
				else
					slot_count += 1
				end
			end

			if slot_count >= cb.duration
				cb.update(computed_time: cb.start_time_slot + i.minutes, is_doable: true)
				return true
			else
				i = j + 1
			end
		end
=end

		# Place the computed break in the available free slot closer to the default time
		default_index = b.default_time - b.start_time_slot
		forward_index = default_index
		backward_index = forward_index - 1
		while (forward_index < doability_bitmask.length or backward_index > 0) do 
			# At each step proceed from the index closest to the default one
			if forward_index - default_index < default_index - backward_index
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
					cb.update(computed_time: cb.start_time_slot + backward_index.minutes, is_doable: true)
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
