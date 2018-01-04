class NotificationController < ApplicationController
	def index
		@user = current_user
		#@pending_meeting = MeetingParticipation.where('response_status = :response_status AND user_id = :user',
		#response_status: MeetingParticipation::Response_statuses[:pending], user: @user.id)
		@pending_meetings = get_invitation(@user)
		@warning_meeting = get_inconsistent_meetings(@user)
		@undoable_breaks = get_undoable_breaks(@user)
	end


	def resolve_warning
		check_if_mine(params[:meeting_participation_id])
		mp = MeetingParticipation.find(params[:meeting_participation_id])
		single_group = [mp]
		single_group = fill_inconsistency(mp, single_group)
		@meeting_participations = single_group
		@user = current_user
	end

	private

	def get_undoable_breaks(user)
		breaks = user.breaks
		undobale = ComputedBreak.where(break_id: breaks.ids, is_doable: false)

		breaks_day = []
		current_day = nil
		if undobale.count > 0
			undobale.each do |ub|
				if current_day.nil? || (ub.start_time_slot.midnight != current_day)
					# Change the current day
					current_day = ub.start_time_slot.midnight
					breaks_day.push current_day
				end
					breaks_day.push ub
			end
		end

		return breaks_day
	end

	def get_invitation(user)
		schedule = []

		meeting_participations = user.meeting_participations.joins(:meeting)
																 .where(response_status: MeetingParticipation::Response_statuses[:pending])
																 .order('meetings.start_date')
		current_day = nil

		meeting_participations.each do |mp|
			if current_day.nil? || (mp.meeting.start_date.midnight != current_day)
				# Change the current day
				current_day = mp.meeting.start_date.midnight
				schedule.push current_day
			end
			schedule.push mp.meeting # maybe push also response status??
		end
		schedule
	end

	def get_inconsistent_meetings(user)
		list_of_all_inconsistencies = []

		inconsistent_mp = user.meeting_participations.joins(:meeting)
													.where(is_consistent: false)
													.where.not(response_status: MeetingParticipation::Response_statuses[:declined])
													.order('meetings.start_date')

		current_day = nil
		inconsistent_mp.each do |mp|

			already_present = false
			list_of_all_inconsistencies.each do |single_group|

				begin
					if single_group.include? mp
						already_present = true
						break
					end
				rescue NoMethodError
					next
				end
			end
			if already_present
				next
			end

			if current_day.nil? || (mp.meeting.start_date.midnight != current_day)
				# Change the current day
				current_day = mp.meeting.start_date.midnight
				list_of_all_inconsistencies.push current_day
			end
			single_group = [mp]
			single_group = fill_inconsistency(mp, single_group)
			list_of_all_inconsistencies.push single_group
		end
		return list_of_all_inconsistencies
	end

	def fill_inconsistency(mp, single_group)
		inconsistent_to_mp = mp.conflicting_meeting_participations

		inconsistent_to_mp.each do |mp_inc|
			unless single_group.include? mp_inc
				single_group.push mp_inc
				single_group = fill_inconsistency(mp_inc, single_group)
			end
		end
		return single_group
	end

	def check_if_mine(meeting_participation_id)
		unless current_user.meeting_participations.where(id: meeting_participation_id).count > 0
			raise ActionController::RoutingError, 'Not Found'
		end
	end
end
