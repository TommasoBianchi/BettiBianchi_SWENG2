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
    @user = User.create(user_params)

    email = Email.create(email: email_hash, user_id: @user.id)
    @user.emails.push(email)
    @user.primary_email_id = email.id

    incomplete_user = IncompleteUser.find_by(email: email.email)
    if @user.save && @user.authenticate(incomplete_user.password)
      log_in @user
      redirect_to @user
    else
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
end
