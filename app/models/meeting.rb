class Meeting < ApplicationRecord
	belongs_to :location
	has_many :meeting_participations
	has_many :users, through: :meeting_participations

	validates :start_date, :end_date, :title, presence: true

	validate :date_consistency

	# This method retrieve all the participants of a meeting
	def get_participants(response_status_number)
		meeting_participations.where(response_status: response_status_number)
	end

	# This method retrieve all the meeting participations linked with the current meeting
	def get_meeting_participaton(user_to_search)
		meeting_participations.find_by(user_id: user_to_search.id)
	end

	private

	# This method check if the dates are consistent
	def date_consistency
		return if [start_date.blank?, end_date.blank?].any?
		errors.add(:end_date, 'must be after start_date') if start_date > end_date
	end
end
