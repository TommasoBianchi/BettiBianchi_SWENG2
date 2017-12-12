class MeetingController < ApplicationController
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
  end

  def create
    puts '****************************************'
    puts(params)
    puts '****************************************'
  end
end
