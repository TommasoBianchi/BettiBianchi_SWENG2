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
		@meeting = Meeting.new
		@users = User.all
		@user_selected = ''
		@user_names = %w[a b]
	end

	def create
		unless check_params_validity(params)
			render 'new'
			return
		end

		title = params[:meeting][:title]
		location_input = params[:meeting][:location].split(',')
		latitude = location_input[0].to_i
		longitude = location_input[1].to_i
		location_name = location_input[2]
		location = Location.find_by(latitude: latitude, longitude: longitude)

		unless location
			location = Location.create(latitude: latitude, longitude: longitude, description: location_name)
		end

		date = params[:meeting][:date].split('/').map {|s| s.to_i}

		start_time = params[:meeting][:start_time].to_datetime
		end_time = params[:meeting][:end_time].to_datetime

		start_date = DateTime.new(date[2], date[0], date[1], start_time.hour, start_time.minute, 0)
		end_date = DateTime.new(date[2], date[0], date[1], end_time.hour, end_time.minute, 0)

		user = current_user

		result = CreateMeetingJob.perform_later start_date.to_i, end_date.to_i, title, location, user

		if result[:status] == :errors
			render 'cc'
		else
			redirect_to meeting_path(id: result[:meeting].id)
			return
		end
		render 'cc'
		id_of_users = params[:meeting][:participants].split(" ")
		puts(params)
		puts(id_of_users)
		puts '****************************************'
	end

	def accept
		session[:return_to] ||= request.referer
		mp = MeetingParticipation.find_by(meeting_id: params[:meeting_id], user_id: params[:user_id])
		mp.response_status = 1
		mp.save
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

	def check_params_validity(params)
		return true
	end
end
