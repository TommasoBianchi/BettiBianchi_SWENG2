class DefaultLocationController < ApplicationController
	skip_before_action :require_one_default_location, :only => [:first_def_location, :first_creation]

	def show
		check_if_mine
		@user = current_user
		@default_location = DefaultLocation.find(params[:id])
		@start_weekday = get_name_of_wday(@default_location.day_of_the_week)
		@start_time = get_time_from_integer(@default_location.starting_hour)
		dt = DateTime.new(2017, 12, 10, 0, 0, 0) + (@default_location.day_of_the_week).days + (@default_location.starting_hour).minutes + 1.minutes
		following_dl = @user.get_first_location_after(dt)
		@end_weekday = get_name_of_wday(following_dl.day_of_the_week)
		@end_time = get_time_from_integer(following_dl.starting_hour)
	end

	def new
		@default_location = DefaultLocation.new
	end

	def create
		user = current_user
		name = params[:default_location][:name]

		if params[:default_location][:location] == ''
			render 'new'
			return
		else
			location_input = params[:default_location][:location].split(',')
			latitude = location_input[0].to_f
			longitude = location_input[1].to_f
			location_name = location_input[2]
			location = Location.find_by(latitude: latitude, longitude: longitude)

			unless location
				location = Location.create(latitude: latitude, longitude: longitude, description: location_name)
			end

		end


		begin
			starting_hour = params[:default_location][:starting_hour].to_datetime.hour * 60 + params[:default_location][:starting_hour].to_datetime.min
		rescue NoMethodError
			render 'new'
			return
		end

		day_of_the_week = get_day_by_name(params[:default_location][:day_of_the_week])
		if day_of_the_week == 'no day'
			render 'new'
			return
		end

		@default_location = DefaultLocation.new(starting_hour: starting_hour, day_of_the_week: day_of_the_week, name: name, user_id: user.id, location_id: location.id)
		if @default_location.valid?
			@default_location.save
			if params[:repetition][:day_of_the_week] == 'daily'
				for i in 1..6
					DefaultLocation.create(starting_hour: starting_hour, day_of_the_week: (day_of_the_week + i) % 7, name: name, user_id: user.id, location_id: location.id)
				end
				days = [0, 1, 2, 3, 4, 5, 6]
				RecomputeMeetingParticipationsJob.perform_later days
			else
				RecomputeMeetingParticipationsJob.perform_later day_of_the_week
			end
			redirect_to @default_location
		else
			render 'new'
			return
		end
	end

	def delete
		check_if_mine(params[:default_location_id])
		check_if_me(params[:user_id].to_i)

		travel_to_drop = Travel.where("starting_location_dl_id = :dl_id OR ending_location_dl_id = :dl_id", dl_id: params[:default_location_id])
		travel_step_to_drop = TravelStep.where(travel_id: travel_to_drop.ids)
		TravelStep.delete(travel_step_to_drop.ids)
		travel_to_drop.each do |travel|
			mp = MeetingParticipation.find_by(arriving_travel_id: travel.id)
			if mp
				mp.arriving_travel_id = nil
				mp.is_consistent = false
				mp.save
			end

			mp = MeetingParticipation.find_by(leaving_travel_id: travel.id)
			if mp
				mp.leaving_travel_id = nil
				mp.is_consistent = false
				mp.save
			end

			travel.delete
		end
		day_of_the_week = [DefaultLocation.find(params[:default_location_id]).day_of_the_week]
		DefaultLocation.delete(params[:default_location_id])
		RecomputeMeetingParticipationsJob.perform_later day_of_the_week, current_user
		redirect_to settings_page_path(id: params[:user_id])
	end

	def first_def_location
		@default_location = DefaultLocation.new
	end

	def first_creation
		user = User.find(params[:user_id])
		name = params[:default_location][:name]

		if params[:default_location][:location] == ''
			render 'first_def_location'
			return
		else
			location_input = params[:default_location][:location].split(',')
			latitude = location_input[0].to_f
			longitude = location_input[1].to_f
			location_name = location_input[2]
			location = Location.find_by(latitude: latitude, longitude: longitude)

			unless location
				location = Location.create(latitude: latitude, longitude: longitude, description: location_name)
			end

		end


		begin
			starting_hour = params[:default_location][:starting_hour].to_datetime.hour * 60 + params[:default_location][:starting_hour].to_datetime.min
		rescue NoMethodError
			render 'first_def_location'
			return
		end

		day_of_the_week = get_day_by_name(params[:default_location][:day_of_the_week])
		if day_of_the_week == 'no day'
			render 'first_def_location'
			return
		end

		@default_location = DefaultLocation.new(starting_hour: starting_hour, day_of_the_week: day_of_the_week, name: name, user_id: user.id, location_id: location.id)
		if @default_location.valid?
			@default_location.save
			if params[:repetition][:day_of_the_week] == 'daily'
				for i in 1..6
					DefaultLocation.create(starting_hour: starting_hour, day_of_the_week: (day_of_the_week + i) % 7, name: name, user_id: user.id, location_id: location.id)
				end
				days = [0, 1, 2, 3, 4, 5, 6]
				RecomputeMeetingParticipationsJob.perform_later days, user
			else
				RecomputeMeetingParticipationsJob.perform_later day_of_the_week, user
			end
			log_in(user)
			redirect_to calendar_day_path
		else
			render 'first_def_location'
			return
		end
	end

	private

	def check_if_mine(id = params[:id])
		unless current_user.default_locations.where(id: id).count > 0
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	def check_if_me(id)
		unless current_user.id == id
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	def check_params_validity
		params.require(:default_location).permit(:name, :day_of_the_week, :starting_hour)

	end


end

