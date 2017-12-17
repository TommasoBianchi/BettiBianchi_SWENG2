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

		MeetingHelper.decline_invitation mp, mp.user

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
end
