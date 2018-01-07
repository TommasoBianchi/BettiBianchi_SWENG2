# This class manages everything related with the homepgae (login, signup)
class HomepageController < ApplicationController

	# This is a constant used to signal errors during the login process
	ERROR_MESSAGE = 'Invalid email/password combination'.freeze

	skip_before_action :require_login

	# This method supports the index page of the system
	def index
		@user = User.new
	end

	# This method manages the request made by the user on the homepage
	def post_index
		return unless validate_input

		email = Email.find_by(email: params[:homepage][:email].downcase)
		user = User.find_by(primary_email_id: email.id) if email

		if params[:signup] # button clicked = signup
			if email
				user_existing_email(user)
			else # email doesn't exist
				if isEmail(params[:homepage][:email].downcase)
					signup_incomplete_user
				else # input is not an email
					nickname_user = User.find_by(nickname: params[:homepage][:email])
					if nickname_user # input corresponds to a valid nickname
						user_existing_email(nickname_user)
					else # guest tries to signup with a non-valid email
						flash.now[:danger] = 'You must register with a valid email'
						render 'index'
					end # end if nickname_user
				end # end isEmail
			end # end if email
		else # button clicked = login
			nickname_user = User.find_by(nickname: params[:homepage][:email])
			if email && user
				user_existing_email(user)
			elsif nickname_user
				user_existing_email(nickname_user)
			else # user doesn't exist
				unless login_incomplete_user # neither an incomplete user exists
					flash.now[:error] = ERROR_MESSAGE
					render 'index'
				end
			end
		end # end button clicked
	end

	# This method permits to the user to log out from the system
	def destroy
		log_out
		redirect_to homepage_path
	end

	private

	# This method redirects the user to the complete registration page
	def go_to_complete_registration(incomplete_user)
		session[:tmp_checked] = incomplete_user.id
		redirect_to '/user/new'
	end

	# This method validates the input of the homepage
	def validate_input
		if params['homepage']['email'].present? && params['homepage']['password'].present?
			true
		else
			flash.now[:danger] = 'Some fields are not filled properly'
			render 'index'
			false
		end
	end

	# This method manages the login of a user that has not completed yet the registration phase
	def login_incomplete_user
		incomplete_user = IncompleteUser.find_by(email: params[:homepage][:email].downcase)
		if incomplete_user && incomplete_user.authenticate(params[:homepage][:password])
			go_to_complete_registration(incomplete_user)
			true
		elsif incomplete_user # incorrect password
			flash.now[:danger] = ERROR_MESSAGE
			render 'index'
			true
		end
	end

	# THis method manages the signup of a new user
	def signup_incomplete_user
		incomplete_user = IncompleteUser.find_by(email: params[:homepage][:email].downcase)
		if incomplete_user && incomplete_user.authenticate(params[:homepage][:password])
			go_to_complete_registration(incomplete_user)
		elsif incomplete_user # incorrect password
			flash.now[:danger] = ERROR_MESSAGE
			render 'index'
		else
			incomplete_user = IncompleteUser.create(email: params[:homepage][:email].downcase, password: params[:homepage][:password], password_confirmation: params[:homepage][:password])
			go_to_complete_registration(incomplete_user)
		end
	end

	# This method manages the correct login of a user. It check if the password is correct and the redirect it to the first page of the system
	def user_existing_email(user)
		if user && user.authenticate(params[:homepage][:password]) # normal registered user
			if user.default_locations.count == 0
				redirect_to create_first_def_location_path(user_id: user.id)
			else
				log_in user
				redirect_to calendar_day_path
			end
		else # registered user that provides a wrong password
			flash.now[:danger] = ERROR_MESSAGE
			render 'index'
		end
	end

end
