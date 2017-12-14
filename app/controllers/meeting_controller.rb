class MeetingController < ApplicationController

	before_action :check_participation, except: [:new, :create]

	def show
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

		if params[:term]
			to_match = '%' + params[:term] + '%'
			@users = User.where("(name ILIKE :search OR surname ILIKE :search OR nickname ILIKE :search) AND id != :current_id", search: to_match, current_id: current_user.id)
		else
			@users = User.all
		end

		respond_to do |format|
			format.html # new.html.erb
			format.json {render :json => @users.to_json}
		end
	end

	def create
		list_of_users = params[:meeting][:participants].split(" ")
		puts(params)
		puts(list_of_users)
		puts '****************************************'
	end

	private
	def check_participation
		meeting_id = params['id']
		meeting_id = params['meeting_id'] unless meeting_id
		unless current_user.meeting_participations.where(meeting_id: meeting_id).count() > 0
			raise ActionController::RoutingError, 'Not Found'
		end
	end
end
