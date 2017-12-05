class HomepageController < ApplicationController
  def index
    @user = User.new
  end

  def post_index
    email = Email.find_by(email: params[:homepage][:email].downcase)
    user = User.find_by(primary_email_id: email.id) if email
    if params[:signup] # button clicked = signup
      if email
        if user && user.authenticate(params[:homepage][:password]) # normal regitered user
          log_in user
          redirect_to user
        elsif user # registered user that provides a wrong password
          flash.now[:danger] = 'Invalid email/password combination'
          render 'index'
        else # unregitered user
          incomplete_user = IncompleteUser.find_by(email: params[:homepage][:email].downcase)
          go_to_complete_regitration(incomplete_user)
        end
      else # email doesn't exist
        incomplete_user = IncompleteUser.create(email: params[:homepage][:email].downcase, password: params[:homepage][:password])
        go_to_complete_regitration(incomplete_user)
      end # end if email
    else # button clicked = login
      if email && user
        if user.authenticate(params[:homepage][:password]) # user exist and password correct
          log_in user
          redirect_to user
        else # user exists but password is incorrect
          flash.now[:danger] = 'Wrong password'
          render 'index'
        end
      else # user doesn't exist
        flash.now[:danger] = 'Invalid email/password combination'
        render 'index'
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
    session[:tmp_checked] = incomplete_user.id
    redirect_to '/user/new'
  end
end
