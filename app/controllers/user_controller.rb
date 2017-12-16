class UserController < ApplicationController
	skip_before_action :require_login

	def show
		require_login
		@user = User.find(params[:id])

	end

	def my_user_page
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
			@unregistered_user = incomplete_user
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
			@unregistered_user = incomplete_user
			render 'new'
		end
	end

	def new
		@unregistered_user = IncompleteUser.find(session[:tmp_checked])
		@user = User.new
		@user.preference_list = '0123'
	end

	def index
		respond_to do |format|
			format.html {html_index}
			format.json {json_index}
		end
	end

	def contacts
		@user = current_user
		puts ("ncjkdscnkdsjcnsdkj")
		puts (@user.id)
		puts(params[:id])
		if @user.id != params[:id].to_i
			raise ActionController::RoutingError, 'Not Found'
		end
		@contacts = @user.contacts
	end

	def delete_contact
		contact_delate_check(params[:user_id], params[:to_delete_id])
		Contact.delete(Contact.where(from_user: params[:user_id], to_user: params[:to_delete_id]))
		redirect_to contacts_page_path(id: params[:user_id])
	end

	def add_contact
		contact_add_check(params[:user_id], params[:to_add_id])
		current_user.contacts.push(User.find(params[:to_add_id]))
		redirect_to contacts_page_path(id: params[:user_id])
	end

	def search
		if params[:term]
			to_match = '%' + params[:term] + '%'
			@users = User.where("(name ILIKE :search OR surname ILIKE :search OR nickname ILIKE :search) AND id != :current_id", search: to_match, current_id: current_user.id)
		else
			@users = User.all
		end

		respond_to do |format|
			format.html # new.html.erb
			format.json {render :json => @users.to_json}
		end
	end

	def search_contacts
		if params[:term]
			to_match = '%' + params[:term] + '%'
			user = current_user
			@users = User.where("(name ILIKE :search OR surname ILIKE :search OR nickname ILIKE :search) AND
					id != :current_id AND id NOT IN (:contacts)", search: to_match, current_id: user.id, contacts: user.contacts.all.ids)
		else
			@users = User.all
		end

		respond_to do |format|
			format.html # new.html.erb
			format.json {render :json => @users.to_json}
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

	def contact_delate_check(user, action_user)
		unless (current_user.id == user.to_i) && (current_user.contacts.where(id: action_user).count() > 0)
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	def contact_add_check(user, action_user)
		unless (current_user.id == user.to_i) && (current_user.contacts.where(id: action_user).count() == 0)
			raise ActionController::RoutingError, 'Not Found'
		end
	end
end
