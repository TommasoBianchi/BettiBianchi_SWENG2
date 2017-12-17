class DefaultLocationController < ApplicationController
	def show
		check_if_mine
		@default_location = DefaultLocation.find(params[:id])
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
			latitude = params[:default_location][:location][0]
			longitude = params[:default_location][:location][1]
			location = Location.find_by(latitude: latitude, longitude: longitude)

			unless location
				location = Location.create(latitude: latitude, longitude: longitude, description: name + ' of ' + user.name + ' ' + user.surname)
			end

		end


		begin
			starting_hour = params[:default_location][:starting_hour].to_datetime.hour * 60 + params[:default_location][:starting_hour].to_datetime.min
		rescue NoMethodError
			render 'new'
			return
		end

		day_of_the_week = get_day_name(params[:default_location][:day_of_the_week])
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
			end
			redirect_to @default_location
		else
			render 'new'
			return
		end
	end

	private

	def check_if_mine(id = params[:id])
		unless current_user.default_locations.where(id: id).count() > 0
			raise ActionController::RoutingError, 'Not Found'
		end
	end

	def check_params_validity
		params.require(:default_location).permit(:name, :day_of_the_week, :starting_hour)

	end

	def get_day_name(day_of_the_week)
		case day_of_the_week
			when "Sunday"
				0
			when "Monday"
				1
			when "Tuesday"
				2
			when "Wednesday"
				3
			when "Thursday"
				4
			when "Friday"
				5
			when "Saturday"
				6
			else
				'no day'
		end
	end
end
