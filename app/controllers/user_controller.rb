class UserController < ApplicationController

  skip_before_action :require_login

  def show
    require_login
    @user = current_user
  end

  def create
    # problems on create user before email and viceversa

    email_hash = params.slice(:user)['user']['email']
    params[:user].delete('email')

    incomplete_user = IncompleteUser.find_by(email: email_hash)
    # render ' '
    # return unless incomplete_user # if it is nil return
    incomplete_user_email = incomplete_user.email
    incomplete_user_psw = incomplete_user.password

    @user = User.new(user_params)
    unless email_hash == incomplete_user_email && incomplete_user.authenticate(@user.password)
      flash.now[:danger] = 'Wrong mail or password'
      render ' '
      render 'new'
    end

    IncompleteUser.delete(incomplete_user.id)
    email = Email.create(email: email_hash)
    @user.emails.push(email)
    @user.primary_email_id = email.id
    last_user = User.last
    email.user_id = User.last.id + 1

    if @user.save
      log_in @user
      redirect_to @user
    else
      reinsertUser(incomplete_user_email, incomplete_user_psw) # to implement but it would be useless
      render 'new'
    end
  end

  def new
    @unregisterdUser = IncompleteUser.find(session[:tmp_checked])
    session[:tmp_checked] = nil # delate temp variable
    @user = User.new
 end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :password, :nickname, :preference_list)
  end

  def reinsertUser(incomplete_user_email, incomplete_user_psw)
    IncompleteUser.create(email: incomplete_user_email, password: incomplete_user_psw, password_confirmation: incomplete_user_psw)
  end
end
