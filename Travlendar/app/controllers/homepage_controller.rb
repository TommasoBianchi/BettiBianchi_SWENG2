class HomepageController < ApplicationController
  Error_message = 'Invalid email/password combination'.freeze

  skip_before_action :require_login

  def index
    @user = User.new
  end

  def post_index
    return unless validate_input

    email = Email.find_by(email: params[:homepage][:email].downcase)
    user = User.find_by(primary_email_id: email.id) if email

    if params[:signup] # button clicked = signup
      if email
        user_existing_email(user)
      else # email doesn't exist
        signup_incomplete_user
      end # end if email
    else # button clicked = login
      if email && user
        user_existing_email(user)
      else # user doesn't exist
        unless login_incomplete_user # neither an incomplete user exists
          flash.now[:danger] = Error_message
          render 'index'
        end
      end
    end # end button clicked
  end

  def login; end

  def destroy
    log_out
    redirect_to root_get_path
  end

  private

  def go_to_complete_regitration(incomplete_user)
    puts(incomplete_user)
    session[:tmp_checked] = incomplete_user.id
    redirect_to '/user/new'
  end

  def validate_input
    if params['homepage']['email'].present? && params['homepage']['password'].present?
      true
    else
      flash.now[:danger] = 'Some fields are not filled properly'
      render 'index'
      false
    end
  end

  def login_incomplete_user
    incomplete_user = IncompleteUser.find_by(email: params[:homepage][:email].downcase)
    if incomplete_user && incomplete_user.authenticate(params[:homepage][:password])
      go_to_complete_regitration(incomplete_user)
      true
    elsif incomplete_user # incorrect password
      flash.now[:danger] = Error_message
      render 'index'
      true
    end
  end

  def signup_incomplete_user
    incomplete_user = IncompleteUser.find_by(email: params[:homepage][:email].downcase)
    if incomplete_user && incomplete_user.authenticate(params[:homepage][:password])
      go_to_complete_regitration(incomplete_user)
    elsif incomplete_user # incorrect password
      flash.now[:danger] = Error_message
      render 'index'
    else
      incomplete_user = IncompleteUser.create(email: params[:homepage][:email].downcase, password: params[:homepage][:password], password_confirmation: params[:homepage][:password])
      go_to_complete_regitration(incomplete_user)
    end
  end

  def create_incomplete_user
    incomplete_user = IncompleteUser.create(email: params[:homepage][:email].downcase, password: params[:homepage][:password], password_confirmation: params[:homepage][:password])
  end

  def user_existing_email(user)
    if user && user.authenticate(params[:homepage][:password]) # normal registered user
      log_in user
      redirect_to user
    else # registered user that provides a wrong password
      flash.now[:danger] = Error_message
      render 'index'
    end
  end
end
