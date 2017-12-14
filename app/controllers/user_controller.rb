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

		incomplete_user = IncompleteUser.find(session[:tmp_checked])
		incomplete_user_email = incomplete_user.email
		incomplete_user_psw = incomplete_user.password

		@user = User.new(user_params)
		unless email_hash == incomplete_user_email && incomplete_user.authenticate(@user.password)
			flash.now[:danger] = 'Wrong mail or password'
			@unregisterdUser = incomplete_user
			render 'new'
			return
		end

		if @user.valid?
			session[:tmp_checked] = nil # delete temp variable
			IncompleteUser.delete(incomplete_user.id)
			email = Email.create(email: email_hash)
			@user.emails.push(email)
			@user.primary_email_id = email.id
			last_user = User.last
			email.user_id = User.last.id + 1
			@user.save
			log_in @user
			redirect_to calendar_day_path DateTime.now.year, DateTime.now.month, DateTime.now.day
		else
			@unregisterdUser = incomplete_user
			render 'new'
		end
	end

	def new
		@unregisterdUser = IncompleteUser.find(session[:tmp_checked])
		@user = User.new
		@user.preference_list = '0123'
	end

	def index
		respond_to do |format|
			format.html {html_index}
			format.json {json_index}
		end
	end


	private

	def html_index
		@users = User.all
	end

	def json_index
		query = begin
			params.permit(:query).fetch(:query)
		rescue
			''
		end
		users = User.where('LOWER(nickname) LIKE LOWER(:query)', query: "%#{query}%")
		render json: users.map(&:name)
	end

	def user_params
		params.require(:user).permit(:name, :surname, :password, :nickname, :preference_list)
	end

	def reinsertUser(incomplete_user_email, incomplete_user_psw)
		IncompleteUser.create(email: incomplete_user_email, password: incomplete_user_psw, password_confirmation: incomplete_user_psw)
	end
end
