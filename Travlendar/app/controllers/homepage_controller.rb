class HomepageController < ApplicationController
  def index
    @user = User.new
  end

  def post_index
    if params[:signup] # user clicks on signup signupbutton
      email = Email.find_by(email: params[:homepage][:email].downcase)
      puts(email)
      if email
        user = User.find_by(primary_email_id: email.id)
        if user && user.authenticate(params[:homepage][:password]) # normal regitered user
          log_in user
          redirect_to user
        elsif user # registered user that provides a wrong password
          flash.now[:danger] = 'Invalid email/password combination'
          render 'index' # SONO ARRIVATO QUA
        else # unregitered user
          @unregisterdUser = {}
          @unregisterdUser['email'] = params[:homepage][:email].downcase
          render 'user/new'
        end
      else # email doesn't exist
        incomplete_user = IncompleteUser.create(email: params[:homepage][:email].downcase, password: params[:homepage][:password])
        @unregisterdUser = {}
        @unregisterdUser['email'] = params[:homepage][:email].downcase
        session[:tmp_checked] = incomplete_user.id
        redirect_to '/user/new'
        # se è negli user nrmali login; se la password è corretta login altrimenti error message
        # else if è negli incomplete_users; se la password è corretta vai alla pagina di complete reg altrimenti errore
      end # end if email
    else # button clicked = login
      email = Email.find_by(email: params[:homepage][:email].downcase)
      puts(email)
      if email && User.find_by(primary_email_id: email.id)
        user = User.find_by(primary_email_id: email.id)
        if user.authenticate(params[:homepage][:password]) # user exist and password correct
          log_in user
          redirect_to user
        else # user exists but password is incorrect
          flash.now[:danger] = 'Wrong password'
          render 'index'
        end
      else # user doesn't exist
        puts '****************************************'
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
