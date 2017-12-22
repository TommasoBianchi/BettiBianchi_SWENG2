class UserController < ApplicationController
	skip_before_action :require_login
	wrap_parameters :user, include: [:nickname, :password, :password_confirmation]

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

	def edit
		@user = current_user
		primary_mail_id = @user.primary_email_id
		@emails = @user.emails.where.not(id: primary_mail_id)
		@email = Email.new
		@datafile = Email.new
	end

	def post_edit
		@user = current_user
		@emails = @user.emails.where.not(id: @user.primary_email_id)
		@email = Email.new
		case params[:commit]
			when "Create Email" #button clicked = Create Email
				email = params[:email][:email]
				if isEmail(email)
					Email.create(email: email, user_id: @user.id)
					redirect_to edit_user_path(id: @user.id)
					return
				else
					@email.errors.add(:email, 'email not valid')
					render 'edit'
					return
				end
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

	def settings
		check_if_myself
		@user = current_user
	end

	def change_preference_list
		check_if_myself
		user = current_user
		user.update_attributes(user_pref_list_params)
		user.save
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
		operator = Operator.find_by(description: params[:constraint][:operator])
		value = Value.find_by(value: params[:constraint][:value])
		c = Constraint.new({travel_mean: travel_mean, subject: subject, operator: operator, value: value, user: current_user})
		if c.valid?
			c.save
			redirect_to settings_page_path
		else
			render 'add_constraint'
		end
	end

	def delete_break
		unless check_delete_break_params
			redirect_to settings_page_path(id: params[:user_id])
			return
		end
		to_delete = ComputedBreak.where(break_id: params[:break_id])
		ComputedBreak.delete(to_delete.ids)
		Break.delete(params[:break_id])
		redirect_to settings_page_path(id: params[:user_id])
	end

	def add_break
		@break = Break.new
	end

	def create_break
		@break = Break.new
		check_if_myself
		unless check_date_consistency(params[:break][:start_time_slot]) && check_date_consistency(params[:break][:end_time_slot]) && check_date_consistency(params[:break][:default_time])
			fill_time_errors
			render 'add_break'
			return
		end

		begin
			starting_hour = params[:break][:start_time_slot].to_datetime.hour * 60 + params[:break][:start_time_slot].to_datetime.min
		rescue NoMethodError
			render 'add_break'
			return
		end


		begin
			ending_hour = params[:break][:end_time_slot].to_datetime.hour * 60 + params[:break][:end_time_slot].to_datetime.min
		rescue NoMethodError
			render 'add_break'
			return
		end

		begin
			default_time_hour = params[:break][:default_time].to_datetime.hour * 60 + params[:break][:default_time].to_datetime.min
		rescue NoMethodError
			render 'add_break'
			return
		end

		unless check_if_consistent_times(starting_hour, default_time_hour, ending_hour)
			fill_time_errors
		end

		day_of_the_week = get_day_by_name(params[:break][:day_of_the_week])
		name = params[:break][:name]
		duration = ending_hour - starting_hour
		user = current_user
		b = Break.create(default_time: default_time_hour, start_time_slot: starting_hour, end_time_slot: ending_hour,
										 duration: duration, name: name, day_of_the_week: day_of_the_week, user_id: user.id)
		#BreakHelper.update_break(b, day?) do i have to pass all mondays(ex) from now to the eternity?
		redirect_to settings_page_path
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

	def user_edit_params
		params.require(:user).permit(:name, :surname, :nickname, :phone_number, :website, :company, :brief)
	end

	def reinsertUser(incomplete_user_email, incomplete_user_psw)
		IncompleteUser.create(email: incomplete_user_email, password: incomplete_user_psw, password_confirmation: incomplete_user_psw)
	end

	def check_if_myself(id = params[:id].to_i)
		unless current_user.id == id
			raise ActionController::RoutingError, 'Not Found'
		end
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

	# method used to check the consistency of params used in constraint add/delate options
	def delete_constraint_check(user, constraint)
		unless (current_user.id == user.to_i) && (current_user.constraints.where(id: constraint).count() > 0)
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	def check_constraint_params
		params.require(:constraint).permit(:travel_mean, :subject, :operator, :value)
	end

	# method used to check the consistency of params used in break add/delate options
	def check_delete_break_params
		params.permit(:break_id, :user_id)
		if params[:user_id].to_i != current_user.id
			return false
		end

		unless Break.find(params[:break_id]).user_id == params[:user_id].to_i
			return false
		end
		return true
	end

	def check_date_consistency(date_from_timepicker)
		params_ok = true
		begin
			date_from_timepicker.to_datetime
		rescue ArgumentError
			params_ok = false
		end

		if date_from_timepicker == ""
			params_ok = false
		end
		return params_ok
	end

	def fill_time_errors
		@break.errors.add(:start_time_slot, 'inconsistent time sequence')
		@break.errors.add(:end_time_slot, 'inconsistent time sequence')
		@break.errors.add(:default_time, 'inconsistent time sequence')
	end

	def check_if_consistent_times(starting_hour, default_time_hour, ending_hour)
		return (starting_hour <= default_time_hour) && (default_time_hour <= ending_hour)
	end

	# method used to check the consistency of params used in delete email
	def check_delete_email_params
		params.permit(:user_id, :email_id)
		unless (current_user.id == params[:user_id].to_i) && (current_user.emails.where(id: params[:email_id]).count() > 0)
			raise ActionController::RoutingError, 'Not Found'
		end
	end

end
