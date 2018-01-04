class MeetingController < ApplicationController

	before_action :check_participation, except: [:new, :create]

	# This method supports the show meeting page
	def show
		@back_path = request.referer
		@user = current_user
		@meeting = Meeting.find(params['id'])
	end

	# This method supports the participants page
	def participants_page
		@user = current_user
		@meeting = Meeting.find(params['id'])
	end

	# This method delete a participant from a meeting
	def remove_from_meeting
		m = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		m.delete
		redirect_to participants_page_path(id: params[:meeting_id])
	end

	# This method nominate admin a participant of the meeting
	def nominate_admin
		m = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		m.is_admin = true
		m.save
		redirect_to participants_page_path(id: params[:meeting_id])
	end

	# This method supports the new meeting page
	def new
		unless @meeting
			@meeting = Meeting.new
		end
		@users = User.all
		@user_selected = ''
		@user_names = %w[a b]
	end

	# This meeting creates the new meeting. It checks if the parameters passed by the user are correct and in the right format
	def create
		@meeting = Meeting.new
		unless check_params_validity(params[:meeting])
			render 'new'
			return
		end

		date = params[:meeting][:date].split('/').map {|s| s.to_i}

		start_time = params[:meeting][:start_time].to_datetime
		end_time = params[:meeting][:end_time].to_datetime

		start_date = DateTime.new(date[0], date[1], date[2], start_time.hour, start_time.minute, 0)
		end_date = DateTime.new(date[0], date[1], date[2], end_time.hour, end_time.minute, 0)

		unless start_date < end_date
			@meeting.errors.add(:start_time, "Not valid")
			@meeting.errors.add(:end_time, "Not valid")
			render 'new'
			return
		end

		title = params[:meeting][:title]
		abstract = params[:meeting][:abstract]

		if params[:meeting][:location] == ''
			render 'new'
			return
		else
			location = get_location(params[:meeting][:location])
		end

		user = current_user
		invited_users = params[:meeting][:participants].split(" ").map {|s| User.find(s.to_i)}
		CreateMeetingJob.perform_later start_date.to_i, end_date.to_i, title, abstract, location, user, invited_users

		redirect_to calendar_day_path(year: date[0], month: date[1], day: date[2])

	end

	# This method is used to accept an invitation to a meeting
	def accept
		session[:return_to] ||= request.referer
		mp = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		mp.response_status = 1
		mp.save
		AcceptInvitationJob.perform_later mp, mp.user
		redirect_to session.delete(:return_to)
	end

	# This method is used to decline an invitation to a meeting
	def decline
		mp = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		mp.response_status = 2
		mp.save

		DeclineInvitationJob.perform_later mp, mp.user

		redirect_to notification_index_path
	end

	private

	# This method checks if the user really participates to that meeting
	def check_participation
		meeting_id = params['id']
		meeting_id = params['meeting_id'] unless meeting_id
		unless current_user.meeting_participations.where(meeting_id: meeting_id, response_status: [0, 1]).count > 0
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	# This method check the validity of the params to create a meeting. It returns params_ok = true iif all the params are correct and in the right format
	def check_params_validity(meeting_params)
		params_ok = true
		if meeting_params[:title] == ""
			@meeting.errors.add(:title, "Not valid")
			params_ok = false
		end

		if meeting_params[:location] == ""
			@meeting.errors.add(:location, "Not valid")
			params_ok = false
		end

		begin
			meeting_params[:start_time].to_datetime
		rescue ArgumentError
			@meeting.errors.add(:start_time, "Not valid")
			params_ok = false
		end

		if meeting_params[:start_time] == ""
			@meeting.errors.add(:start_time, "Not valid")
			params_ok = false
		end

		begin
			meeting_params[:end_time].to_datetime
		rescue ArgumentError
			@meeting.errors.add(:end_time, "Not valid")
			params_ok = false
		end

		if meeting_params[:end_time] == ""
			@meeting.errors.add(:end_time, "Not valid")
			params_ok = false
		end

		begin
			meeting_params[:date].to_datetime
		rescue ArgumentError
			@meeting.errors.add(:date, "Not valid")
			params_ok = false
		end

		if meeting_params[:date] == ""
			@meeting.errors.add(:date, "Not valid")
			params_ok = false
		end

		params_ok
	end


end
