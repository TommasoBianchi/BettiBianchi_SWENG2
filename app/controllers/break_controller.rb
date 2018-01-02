class BreakController < ApplicationController

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
		break_params = {}
		unless check_date_consistency(params[:break][:start_time_slot]) && check_date_consistency(params[:break][:end_time_slot]) && check_date_consistency(params[:break][:default_time])
			fill_time_errors
			render 'add_break'
			return
		end
		break_params[]
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

		duration = params[:break][:duration].to_i
		if duration < 1
			@break.errors.add(:duration, 'Negative duration is not valid')
		end

		day_of_the_week = get_day_by_name(params[:break][:day_of_the_week])
		name = params[:break][:name]
		user = current_user
		new_break = Break.create(default_time: default_time_hour, start_time_slot: starting_hour, end_time_slot: ending_hour,
														 duration: duration, name: name, day_of_the_week: day_of_the_week, user_id: user.id)
		BreakHelper.full_update_break(new_break)
		redirect_to settings_page_path
	end

	private

	def check_delete_break_params
		params.permit(:break_id, :user_id)
		if params[:user_id].to_i != current_user.id
			return false
		end

		unless Break.find(params[:break_id]).user_id == params[:user_id].to_i
			return false
		end
		true
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
		params_ok
	end

	def fill_time_errors
		@break.errors.add(:start_time_slot, 'inconsistent time sequence')
		@break.errors.add(:end_time_slot, 'inconsistent time sequence')
		@break.errors.add(:default_time, 'inconsistent time sequence')
	end

	def check_if_consistent_times(starting_hour, default_time_hour, ending_hour)
		(starting_hour <= default_time_hour) && (default_time_hour <= ending_hour)
	end

end
