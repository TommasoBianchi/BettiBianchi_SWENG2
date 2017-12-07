class MeetingController < ApplicationController
  def show
    @user = current_user
    @meeting = Meeting.find(2)
    @meeting.abstract = 'prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova prova '
  end

  def participants_page
    @user = current_user
    @meeting = Meeting.find(params['format'])
  end
end
