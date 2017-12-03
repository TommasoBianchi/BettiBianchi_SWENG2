class UserController < ApplicationController
  def show; end

  def create
    # problems on create user before email and viceversa
    email_hash = params.slice(:user)['user']['email']
    params[:user].delete('email')
    @user = User.create(user_params)
    email = Email.create(email: email_hash, user_id: @user.id)
    @user.emails.push(email)
    @user.primary_email_id = email.id
    if @user.save
      log_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def new
    @user = User.new
 end

  def check_presence
    params[:user].present? &&
      params[:user][:email].present? &&
      params[:user][:password].present?
  end

  def validate_presence
    puts '****************************************'
  end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :password, :nickname, :preference_list)
  end
end
