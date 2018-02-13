# This is a helper module containing functions to be called to update the scheduling of meeting participations
module MeetingHelper

	# This function has to be called to create both a meeting and a meeting_participation and store them on the db.
	#
	# In practice, use this only for the user that creates a meeting and not for the invited users
	#
	# * start_date and end_date must be valid DateTime objects
	# * title must be a non-empty string
	# * location must be a Location already saved in the db
	# * user must be a User
	#
	# returns a hash containing the meeting (nil in case of errors), the meeting_participation (nil in case of errors)
	# and a status flag (encoded as a Ruby Symbol) indicating either consistency, inconsistency or errors
	def self.create_meeting(start_date, end_date, title, abstract, location, user)
		if start_date >= end_date
			return {meeting: nil, meeting_participation: nil, status: :errors}
		end

		meeting_data = insert_meeting({start_date: start_date, end_date: end_date, location: location}, user)

		####### Store the meeting and the meeting participation
		meeting = Meeting.new({start_date: start_date, end_date: end_date, title: title, location: location, abstract: abstract})
		meeting_participation = MeetingParticipation.new
		meeting_participation.meeting = meeting
		meeting_participation.is_admin = true
		meeting_participation.user = user
		meeting_participation.is_consistent = meeting_data[:is_consistent]
		meeting_participation.response_status = MeetingParticipation::Response_statuses[:accepted]

		####### If meeting participation is not consistent break out of this function
		if meeting_data[:is_consistent] == false
			sleep 5 if (ENV.fetch("RAILS_ENV") { "development" } == "test") # Fix needed to handle nested transactions
			ActiveRecord::Base.transaction do
				meeting.save
				meeting_participation.save
				meeting_data[:conflict_set].each do |id|
					# insert in conflict set
					MeetingParticipationConflict.create({meeting_participation_1_id: meeting_participation.id, meeting_participation_2_id: id})
				end
			end
			return {meeting: meeting, meeting_participation: meeting_participation, status: :inconsistent}
		end

		#######################
		# From here on we are dealing with only consistent meeting participations
		#######################

		####### Store the arriving travel
		arriving_travel, arriving_travel_steps = store_travel meeting_data[:arriving_travel]

		# Link the starting default location if needed
		arriving_travel.starting_location_dl = meeting_data[:arriving_from_dl] if meeting_data[:arriving_from_dl]

		# Update the leaving travel of the last meeting before the new one if needed
		if meeting_data[:link_before_meeting]
			meeting_data[:before_meeting].leaving_travel = arriving_travel
		end
		valid_before_meeting = (!meeting_data[:link_before_meeting] or meeting_data[:before_meeting].valid?)

		####### Store the leaving travel
		leaving_travel, leaving_travel_steps = store_travel meeting_data[:leaving_travel]

		# Link the ending default location if needed
		leaving_travel.ending_location_dl = meeting_data[:leaving_to_dl] if meeting_data[:leaving_to_dl]

		# Update the arriving travel of the first meeting after the new one if needed
		if meeting_data[:link_after_meeting]
			meeting_data[:after_meeting].arriving_travel = leaving_travel
		end
		valid_after_meeting = (!meeting_data[:link_after_meeting] or meeting_data[:after_meeting].valid?)

		meeting_participation.arriving_travel = arriving_travel
		meeting_participation.leaving_travel = leaving_travel

		####### If everything can be successfully validated, persist it on the db
		if [meeting.valid?, meeting_participation.valid?, arriving_travel.valid?, leaving_travel.valid?,
			valid_before_meeting, valid_after_meeting].all?
			ActiveRecord::Base.transaction do
				meeting.save
				meeting_participation.save
				arriving_travel.save
				arriving_travel_steps.each do |step| step.save end
				leaving_travel.save
				leaving_travel_steps.each do |step| step.save end
				if meeting_data[:link_before_meeting]
					meeting_data[:before_meeting].save
				end
				if meeting_data[:link_after_meeting]
					meeting_data[:after_meeting].save
				end
			end

			BreakHelper.update_all_breaks(arriving_travel.start_time, leaving_travel.end_time, user)

			return {meeting: meeting, meeting_participation: meeting_participation, status: :consistent}
		else
			# Print errors
			Rails.logger.debug "------------ ERRORS (MeetingHelper.create_meeting) ------------"
			Rails.logger.debug "Meeting has errors" unless meeting.valid?
			Rails.logger.debug "Meeting participation has errors" unless meeting_participation.valid?
			Rails.logger.debug "Arriving travel has errors" unless arriving_travel.valid?
			Rails.logger.debug "Leaving travel has errors" unless leaving_travel.valid?
			Rails.logger.debug "Before meeting has errors" unless valid_before_meeting
			Rails.logger.debug "After meeting has errors" unless valid_after_meeting
			Rails.logger.debug "------------ ERRORS (MeetingHelper.create_meeting) ------------"
			return {meeting: nil, meeting_participation: nil, status: :errors}
		end
	end

	# This function has to be called to create only a meeting_participation (for an already existing meeting) and store it on the db.
	# 
	# In practice, use this only for the invited users and not for the user that creates a meeting
	#
	# * meeting must be a Meeting already saved in the db
	# * user must be a User
	#
	# returns a hash containing the meeting_participation (nil in case of errors) and a status flag (encoded as a Ruby Symbol) 
	# indicating either consistency, inconsistency or errors
	def self.invite_to_meeting(meeting, user)
		meeting_data = insert_meeting({start_date: meeting.start_date, end_date: meeting.end_date, location: meeting.location}, user)

		####### Store the meeting participation
		meeting_participation = MeetingParticipation.new
		meeting_participation.meeting = meeting
		meeting_participation.is_admin = false
		meeting_participation.user = user
		meeting_participation.is_consistent = meeting_data[:is_consistent]
		meeting_participation.response_status = MeetingParticipation::Response_statuses[:pending]

		####### If meeting participation is not consistent break out of this function
		if meeting_data[:is_consistent] == false
			ActiveRecord::Base.transaction do
				meeting_participation.save
				meeting_data[:conflict_set].each do |id|
					# insert in conflict set
					MeetingParticipationConflict.create({meeting_participation_1_id: meeting_participation.id, meeting_participation_2_id: id})
				end
			end
			return {meeting_participation: meeting_participation, status: :inconsistent}
		end

		#######################
		# From here on we are dealing with only consistent meeting participations
		#######################

		####### Store the arriving travel
		arriving_travel, arriving_travel_steps = store_travel meeting_data[:arriving_travel]

		# Link the starting default location if needed
		arriving_travel.starting_location_dl = meeting_data[:arriving_from_dl] if meeting_data[:arriving_from_dl]

		# Update the leaving travel of the last meeting before the new one if needed
		if meeting_data[:link_before_meeting]
			meeting_data[:before_meeting].leaving_travel = arriving_travel
		end
		valid_before_meeting = (!meeting_data[:link_before_meeting] or meeting_data[:before_meeting].valid?)

		####### Store the leaving travel
		leaving_travel, leaving_travel_steps = store_travel meeting_data[:leaving_travel]

		# Link the ending default location if needed
		leaving_travel.ending_location_dl = meeting_data[:leaving_to_dl] if meeting_data[:leaving_to_dl]

		# Update the arriving travel of the first meeting after the new one if needed
		if meeting_data[:link_after_meeting]
			meeting_data[:after_meeting].arriving_travel = leaving_travel
		end
		valid_after_meeting = (!meeting_data[:link_after_meeting] or meeting_data[:after_meeting].valid?)

		meeting_participation.arriving_travel = arriving_travel
		meeting_participation.leaving_travel = leaving_travel

		####### If everything can be successfully validated, persist it on the db
		if [meeting_participation.valid?, arriving_travel.valid?, leaving_travel.valid?,
			valid_before_meeting, valid_after_meeting].all?
			ActiveRecord::Base.transaction do
				meeting_participation.save
				arriving_travel.save
				arriving_travel_steps.each do |step| step.save end
				leaving_travel.save
				leaving_travel_steps.each do |step| step.save end
				if meeting_data[:link_before_meeting]
					meeting_data[:before_meeting].save
				end
				if meeting_data[:link_after_meeting]
					meeting_data[:after_meeting].save
				end
			end
			return {meeting_participation: meeting_participation, status: :consistent}
		else
			# Print errors
			Rails.logger.debug "------------ ERRORS (MeetingHelper.invite_to_meeting) ------------"
			Rails.logger.debug "Meeting participation has errors" unless meeting_participation.valid?
			Rails.logger.debug "Arriving travel has errors" unless arriving_travel.valid?
			Rails.logger.debug "Leaving travel has errors" unless leaving_travel.valid?
			Rails.logger.debug "Before meeting has errors" unless valid_before_meeting
			Rails.logger.debug "After meeting has errors" unless valid_after_meeting
			Rails.logger.debug "------------ ERRORS (MeetingHelper.invite_to_meeting) ------------"
			return {meeting_participation: nil, status: :errors}
		end
	end

	# Update the schedule after accepting the invitation to a meeting
	#
	# * meeting_participations is a MeetingParticipation
	# * user is a User
	def self.accept_invitation(meeting_participation, user)
		update_schedule([meeting_participation])
	end

	# Update the schedule after declining the invitation to a meeting
	# 
	# As a result some other MeetingParticipations may become consistent
	#
	# * meeting_participation is a MeetingParticipation
	# * user is a User
	def self.decline_invitation(meeting_participation, user)
		# Grab all conflicting meeting participations from the db
		conflicts = meeting_participation.conflicting_meeting_participations

		update_schedule(conflicts)
	end

	# Update the schedule for a given user and for all the given days of the week
	#
	# * days_of_the_week is an Array of Integers in range 0..6
	# * user is a User
	def self.recompute_meeting_participations(days_of_the_week, user)
		# Grab all the meeting participations to recompute
		meeting_participations = user.meeting_participations
									.where.not(response_status: MeetingParticipation::Response_statuses[:declined])
									.select {|mp| days_of_the_week.include? mp.meeting.start_date.wday}

		# Update the schedule
		update_schedule(meeting_participations)
	end

	private
	def self.insert_meeting(new_meeting, user)
		user_meetings = user.meeting_participations.joins(:meeting).where.not(response_status: MeetingParticipation::Response_statuses[:declined])
		# These are actually MeetingParticipation
		overlapping_meetings = user_meetings.where('meetings.start_date between ? and ?', new_meeting[:start_date], new_meeting[:end_date])
								.or(user_meetings.where('meetings.end_date between ? and ?', new_meeting[:start_date], new_meeting[:end_date]))
								.or(user_meetings.where('"meetings"."start_date" <= ?', new_meeting[:start_date])
												 .where('"meetings"."end_date" >= ?', new_meeting[:end_date]))
		overlapping_meetings.each do |mp|
			mp.update({is_consistent: false})
			new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
			new_meeting[:conflict_set].push mp.id
		end

		unless overlapping_meetings.empty?
			new_meeting[:is_consistent] = false
			return new_meeting
		end

		defloc_before = user.get_last_default_location_before new_meeting[:start_date]
		defloc_after = user.get_last_default_location_before new_meeting[:end_date]

		arriving_travel = TravelHelper.best_travel(defloc_before.location, new_meeting[:location], user, nil, new_meeting[:start_date])
		new_meeting[:arriving_from_dl] = defloc_before
		leaving_travel = TravelHelper.best_travel(new_meeting[:location], defloc_after.location, user, new_meeting[:end_date], nil)
		new_meeting[:leaving_to_dl] = defloc_after

		# These are actually MeetingParticipation
		before_meeting = user_meetings.where(is_consistent: true)
						.where('"meetings"."end_date" < ?', new_meeting[:start_date]).order('meetings.end_date').last
		after_meeting = user_meetings.where(is_consistent: true)
						.where('"meetings"."start_date" > ?', new_meeting[:end_date]).order('meetings.start_date').first

		if before_meeting != nil and (arriving_travel == nil or arriving_travel[:duration] > (new_meeting[:start_date].to_i - before_meeting.leaving_travel.end_time.to_i))
			new_meeting[:arriving_from_dl] = nil
			arriving_travel = TravelHelper.best_travel(before_meeting.meeting.location, new_meeting[:location], user, before_meeting.meeting.end_date, nil)
			if arriving_travel == nil or (arriving_travel[:duration] > (new_meeting[:start_date].to_i - before_meeting.meeting.end_date.to_i))
				new_meeting[:is_consistent] = false
				before_meeting.update({is_consistent: false})
				new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
				new_meeting[:conflict_set].push before_meeting.id
				return new_meeting
			else
				new_meeting[:link_before_meeting] = true
				new_meeting[:before_meeting] = before_meeting
			end
		end

		if after_meeting != nil and (leaving_travel == nil or leaving_travel[:duration] > (after_meeting.arriving_travel.start_time.to_i - new_meeting[:end_date].to_i))
			new_meeting[:leaving_to_dl] = nil
			leaving_travel = TravelHelper.best_travel(new_meeting[:location], after_meeting.meeting.location, user, new_meeting[:end_date], nil)
			if leaving_travel == nil or (leaving_travel[:duration] > (after_meeting.meeting.start_date - new_meeting[:end_date]))
				new_meeting[:is_consistent] = false
				after_meeting.update({is_consistent: false})
				new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
				new_meeting[:conflict_set].push after_meeting.id
				return new_meeting
			else
				new_meeting[:link_after_meeting] = true
				new_meeting[:after_meeting] = after_meeting
			end
		end

		new_meeting[:is_consistent] = true
		new_meeting[:arriving_travel] = arriving_travel
		new_meeting[:leaving_travel] = leaving_travel
		return new_meeting
	end

	def self.get_autocomplete_location(location)
		url = "#{BaseURL}?input=#{location}&types=geocode&key#{GoogleAPIKey}"

		response = RestClient::Request.execute(method: :get, url: url)
		json_response = JSON.parse(response)

		if json_response['status'] != 'OK'
			# raise error?
			return json_response
		end

		all_predictions = json_response['predictions']
		list_locations = []
		all_predictions.each do |prediction|
		location = {
			description: prediction['description'],
			place_id: prediction['place_id']
		}
		list_locations.push(location)
		end

		list_locations
	end

	def self.store_travel(data)
		# Store the travel
		travel = Travel.new
		travel.start_time = data[:start_time]
		travel.end_time = data[:end_time]
		travel.travel_mean = Travel::Travel_means[data[:travel_mean]]
		travel.distance = data[:distance]
		
		# Store the travel steps
		travel_steps = []
		previous_step_start_time = travel.start_time
		data[:steps].each do |step|
			travel_step = TravelStep.new
			travel_step.travel_mean = Travel::Travel_means[step[:travel_mean]]
			travel_step.distance = step[:distance]
			travel_step.travel = travel

			travel_step.description = step[:details]
			travel_step.from = step[:departure_stop] if step[:departure_stop]
			travel_step.to = step[:arrival_stop] if step[:arrival_stop]

			travel_step.start_time = if step[:departure_time] then step[:departure_time] else previous_step_start_time end
			travel_step.end_time = if step[:arrival_time] then step[:arrival_time] else previous_step_start_time + step[:duration].seconds end
			previous_step_start_time = travel_step.end_time

			travel_steps.push travel_step
		end

		return [travel, travel_steps]
	end

	def self.update_schedule(meeting_participations_to_recompute)
		meeting_participations_to_recompute.each do |mp|
			Rails.logger.debug "Meeting participation #{mp.id} is being recomputed"

			arriving_travel = mp.arriving_travel
			leaving_travel = mp.leaving_travel
			meeting = mp.meeting
			response_status = mp.response_status

			# Drop all the conflicts
			conflicts = mp.conflicting_meeting_participations
			MeetingParticipationConflict.where(meeting_participation_1_id: conflicts.ids)
				.or(MeetingParticipationConflict.where(meeting_participation_2_id: conflicts.ids)).delete_all

			mp.delete

			if arriving_travel
				arriving_travel.travel_steps.each do |step|
					step.delete
				end
				# If another meeting participation is linked to this travel, drop the link
				MeetingParticipation.where(leaving_travel: arriving_travel).update(leaving_travel: nil, is_consistent: false)
				arriving_travel.delete
			end
			if leaving_travel
				leaving_travel.travel_steps.each do |step|
					step.delete
				end
				# If another meeting participation is linked to this travel, drop the link
				MeetingParticipation.where(arriving_travel: leaving_travel).update(arriving_travel: nil, is_consistent: false)
				leaving_travel.delete
			end

			result = invite_to_meeting meeting, mp.user
			unless result[:status] == :errors
				result[:meeting_participation].update({response_status: response_status})
			end

			Rails.logger.debug "Meeting participation for meeting #{meeting.id} and for user #{mp.user.id}" + 
								" successfully recomputed (mp id: #{result[:meeting_participation].id})"

			from_date = if result[:meeting_participation].arriving_travel 
				then result[:meeting_participation].arriving_travel.start_time else meeting.start_date end
			to_date = if result[:meeting_participation].leaving_travel 
				then result[:meeting_participation].leaving_travel.end_time else meeting.end_date end
			BreakHelper.update_all_breaks(from_date, to_date, mp.user)
		end		
	end

	# This is a constant that contains the google API Key used to get the travels from google
	GoogleAPIKey = 'AIzaSyDba6PxTVz-07hIVjksboJ4AEkOP2WeuAs'.freeze

	# This constant represent the base path used for autocomplete
	BaseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'.freeze
end
