class HomepageController < ApplicationController
  def index
    @user = User.new
  end

  def post_index
    if params[:signup]
      flash[:success] = 'Welcome to the new User!'
      redirect_to new_user_path
    else
      # email = Email.find_by(email: params[:homepage][:email].downcase)
      email = Email.find_by(email: params[:homepage][:email])
      puts(email)
      if email && User.find_by(primary_email_id: email.id)
        user = User.find_by(primary_email_id: email.id)
        if user.authenticate(params[:homepage][:password])
          log_in user
          redirect_to user
        end
      else
        flash.now[:danger] = 'Invalid email/password combination'
        render 'index'
      end
      ## check presence of the user and redirect him to the homepage
      puts(params)
    end
  end

  def login; end

  def destroy
    log_out
    redirect_to root_get_path
    end

  def complete_registration
    @old_values = { email: params['email'] }
    puts '****************************************'
    puts(params)
  end
end
