# This class manages the model(relations, validations and base methods) of the Travel object
class Travel < ApplicationRecord
	# This should be a constant
	Travel_means = {
			walking: 0,
			driving: 1,
			public_transportation: 2,
			biking: 3
	}.freeze

	has_many :travel_steps

	belongs_to :starting_location_dl, class_name: 'DefaultLocation', foreign_key: 'starting_location_dl_id', required: false
	has_one :starting_location_meeting, class_name: 'MeetingParticipation', foreign_key: 'leaving_travel_id', required: false
	belongs_to :ending_location_dl, class_name: 'DefaultLocation', foreign_key: 'ending_location_dl_id', required: false
	has_one :ending_location_meeting, class_name: 'MeetingParticipation', foreign_key: 'arriving_travel_id', required: false

	validates :start_time, :end_time, :distance, :travel_mean, presence: true

	validate :date_consistency
	validate :travel_mean_correctness


	# This method returns the duration of the travel in minutes
	def get_duration_integer_minutes
		((end_time - start_time) / 60).to_i
	end

	# This method returns the user that has to perform the travel
	def get_user
		if starting_location_dl.present?
			starting_location_dl.user
		elsif ending_location_dl.present?
			ending_location_dl.user
		elsif starting_location_meeting.present?
			starting_location_meeting.user
		elsif ending_location_meeting.present?
			ending_location_meeting.user
		end
	end

	# This method returns the starting point of a travel
	def get_starting_point
		if starting_location_meeting.blank?
			starting_location_dl
		else
			starting_location_meeting
		end
	end

	# This method returns the ending point of a travel
	def get_ending_point
		if ending_location_meeting.blank?
			ending_location_dl
		else
			ending_location_meeting
		end
	end

	private

	# This method checks if the starting and ending time are consistent
	def date_consistency
		return if [start_time.blank?, end_time.blank?].any?
		errors.add(:start_time, 'must be after end_time') if start_time > end_time
	end

	# This method checks if the travel mean chosen for the travel is in the available ones
	def travel_mean_correctness
		return if travel_mean.blank?
		unless Travel_means.values.include? travel_mean
			errors.add(:travel_mean, "must be one between #{Travel_means.values}")
		end
	end

end
