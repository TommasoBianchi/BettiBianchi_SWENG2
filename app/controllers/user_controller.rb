class UserController < ApplicationController
	skip_before_action :require_login
	wrap_parameters :user, include: [:nickname, :password, :password_confirmation]

	def show
		require_login
		@user = User.find(params[:id])
		@socials = Social::Social_type
	end

	def my_user_page
		@user = current_user
	end

	def create
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
			email.user_id = if User.last then
												User.last.id + 1
											else
												1
											end
			@user.save
			log_in @user
			redirect_to create_first_def_location_path(user_id: @user.id)
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

	def edit
		@user = current_user
		primary_mail_id = @user.primary_email_id
		@emails = @user.emails.where.not(id: primary_mail_id)
		@email = Email.new
		@datafile = Email.new
		@socials = Social::Social_type
	end

	def post_edit
		@user = current_user
		@emails = @user.emails.where.not(id: @user.primary_email_id)
		@email = Email.new
		case params[:commit]
			when "Create Email" #button clicked = Create Email
				email_params = {}
				email_params[:email] = params[:email][:email]
				email_params[:user_id] = @user.id
				e = Email.new(email_params)
				if e.save
					redirect_to edit_user_path(id: @user.id)
					return
				else
					flash.now[:error] = 'Email not valid!'
					@email.errors.add(:email, 'email not valid')
					render 'edit'
					return
				end
			when "Create Social" #button clicked = Create Social
				s = SocialUser.create(social_id: params[:social_user][:social], user_id: params[:id], link: params[:social_user][:link])
				redirect_to @user
			when "Edit User" #button clicked = Edit User
				if @user.update_attributes(user_edit_params)
					redirect_to @user
				else
					render 'edit'
				end
			when "Upload Image"
				uploaded_io = params[:file]
				File.open(Rails.root.join('public', 'profile_images', @user.primary_email.email + ".png"), 'wb') do |file|
					file.write(uploaded_io.read)
				end
				redirect_to @user
				return
			else
				redirect_to edit_user_path(id: current_user.id)
		end
	end


	def delete_email
		check_delete_email_params
		Email.delete(params[:email_id])
		redirect_to user_path(id: params[:user_id])
	end


	def contacts
		@user = current_user
		puts ("ncjkdscnkdsjcnsdkj")
		puts (@user.id)
		puts(params[:id])
		check_if_myself
		@contacts = @user.contacts
	end

	def delete_contact
		contact_delate_check(params[:user_id], params[:to_delete_id])
		Contact.delete(Contact.where(from_user: params[:user_id], to_user: params[:to_delete_id]))
		redirect_to contacts_page_path(id: params[:user_id])
	end

	def add_contact
		check_if_myself(params[:user_id])
		user = User.find(params[:user_id])
		to_add = User.find(params[:to_add_id])
		if to_add && user != to_add && !Contact.where(from_user: user.id).ids.include?(to_add.id)
			user.contacts.push(to_add)
			user.save
			redirect_to contacts_page_path(id: params[:user_id])
		else
			raise ActionController::RoutingError, 'Not Found'
		end
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

	def settings
		check_if_myself
		@user = current_user
	end

	def change_preference_list
		check_if_myself
		user = current_user
		new_preference_list = user_pref_list_params[:preference_list]
		if new_preference_list != user.preference_list
			user.update_attributes(user_pref_list_params)
			user.save
			RecomputeMeetingParticipationsJob.perform_later (0..6).to_a, user
		end
		redirect_to settings_page_path
	end

	def user_pref_list_params
		params.require(:user).permit(:preference_list)
	end

	def delate_constraint
		delete_constraint_check(params[:user_id], params[:constraint_id])
		Constraint.delete(params[:constraint_id])
		redirect_to settings_page_path(id: params[:user_id])
	end

	def add_constraint
		@constraint = Constraint.new
		@operators = Operator.all
		@values = Value.all
	end

	def create_constraint
		travel_mean = params[:constraint][:travel_mean]
		subject = Subject.find(params[:constraint][:subject].to_i)
		operator = Operator.find_by(description: params[:constraint][:operator], subject_id: subject.id)
		value = Value.find_by(value: params[:constraint][:value], subject_id: subject.id)
		c = Constraint.new({travel_mean: travel_mean, subject: subject, operator: operator, value: value, user: current_user})
		if c.save
			redirect_to settings_page_path
		else
			render 'add_constraint'
		end
	end

	def delete_social
		check_if_myself(params[:user_id])
		SocialUser.find(params[:social_user_id]).delete
		redirect_to current_user
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
		params.require(:user).permit(:name, :surname, :password, :nickname, :preference_list, :brief)
	end

	def user_edit_params
		params.require(:user).permit(:name, :surname, :nickname, :phone_number, :website, :company, :brief)
	end

	def reinsertUser(incomplete_user_email, incomplete_user_psw)
		IncompleteUser.create(email: incomplete_user_email, password: incomplete_user_psw, password_confirmation: incomplete_user_psw)
	end

	def check_if_myself(id = params[:id].to_i)
		unless current_user.id == id.to_i
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	def contact_delate_check(user, action_user)
		unless (current_user.id == user.to_i) && (current_user.contacts.where(id: action_user).count > 0)
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	def contact_add_check(user, action_user)
		unless (current_user.id == user.to_i) && (current_user.contacts.where(id: action_user).count == 0)
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	# method used to check the consistency of params used in constraint add/delate options
	def delete_constraint_check(user, constraint)
		unless (current_user.id == user.to_i) && (current_user.constraints.where(id: constraint).count > 0)
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	def check_constraint_params
		params.require(:constraint).permit(:travel_mean, :subject, :operator, :value)
	end


	# method used to check the consistency of params used in delete email
	def check_delete_email_params
		params.permit(:user_id, :email_id)
		unless (current_user.id == params[:user_id].to_i) && (current_user.emails.where(id: params[:email_id]).count > 0)
			raise ActionController::RoutingError, 'Not Found'
		end
	end

end
