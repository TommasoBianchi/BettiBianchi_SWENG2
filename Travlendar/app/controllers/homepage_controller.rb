class HomepageController < ApplicationController
  def index
    @user = User.new
  end

  def post_index
    redirect_to complete_registration_url if params[:signup]
    end

  def to_delate
    if
      @user = User.new
      email = Email.create(params[:email])
      params.delete('email')
      @user.emails.push(email)
      @user.primary_email_id = email.id
      # UserController.newSmallUser
      if @user.save
        redirect_to complete_registration_path
      else
        redirect_to error_path
      end
    else
      puts('perform a login')
    end
  end

  def complete_registration
    puts '****************************************'
    email_hash = params.slice(:user)['user']['email']
    params[:user].delete('email')
    user = User.new(user_params)
    email = Email.create(email: email_hash, user_id: user.id)
    user.emails.push(email)
    user.primary_email_id = email.id
    # UserController.newSmallUser

    if user.save
      user.show
    else
      redirect_to error_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :password, :nickname, :preference_list)
  end
end
