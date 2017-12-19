class MeetingController < ApplicationController

	before_action :check_participation, except: [:new, :create]

	def show
		@back_path = request.referer
		@user = current_user
		@meeting = Meeting.find(params['id'])
		@meeting.abstract = 'prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova '
	end

	def participants_page
		@user = current_user
		@meeting = Meeting.find(params['id'])
	end

	def remove_from_meeting
		m = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		m.delete
		redirect_to participants_page_path(id: params[:meeting_id])
	end

	def nominate_admin
		m = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		m.is_admin = true
		m.save
		redirect_to participants_page_path(id: params[:meeting_id])
	end

	def new
		unless @meeting
			@meeting = Meeting.new
		end
		@users = User.all
		@user_selected = ''
		@user_names = %w[a b]
	end

	def create
		@meeting = Meeting.new
		unless check_params_validity(params[:meeting])
			render 'new'
			return
		end

		date = params[:meeting][:date].split('/').map {|s| s.to_i}

		start_time = params[:meeting][:start_time].to_datetime
		end_time = params[:meeting][:end_time].to_datetime

		start_date = DateTime.new(date[2], date[0], date[1], start_time.hour, start_time.minute, 0)
		end_date = DateTime.new(date[2], date[0], date[1], end_time.hour, end_time.minute, 0)

		unless start_date < end_date
			@meeting.errors.add(:start_time, "Not valid")
			@meeting.errors.add(:end_time, "Not valid")
			render 'new'
			return
		end

		title = params[:meeting][:title]
		abstract = params[:meeting][:abstract]
		location_input = params[:meeting][:location].split(',')
		latitude = location_input[0].to_i
		longitude = location_input[1].to_i
		location_name = location_input[2]
		location = Location.find_by(latitude: latitude, longitude: longitude)

		unless location
			location = Location.create(latitude: latitude, longitude: longitude, description: location_name)
		end

		user = current_user
		invited_users = params[:meeting][:participants].split(" ").map {|s| User.find(s.to_i)}
		CreateMeetingJob.perform_later start_date.to_i, end_date.to_i, title, abstract, location, user, invited_users

		redirect_to calendar_day_path(year: date[2], month: date[0], day: date[1])

	end

	def accept
		session[:return_to] ||= request.referer
		mp = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		mp.response_status = 1
		mp.save
		AcceptInvitationJob.perform_later mp, mp.user
		redirect_to session.delete(:return_to)
	end

	def decline
		mp = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		mp.response_status = 2
		mp.save

		DeclineInvitationJob.perform_later mp, mp.user

		redirect_to notification_index_path
	end

	private
	def check_participation
		meeting_id = params['id']
		meeting_id = params['meeting_id'] unless meeting_id
		unless current_user.meeting_participations.where(meeting_id: meeting_id, response_status: [0, 1]).count() > 0
			raise ActionController::RoutingError, 'Not Found'
		end
	end

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
