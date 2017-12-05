class MeetingParticipation < ApplicationRecord
	# This should be a constant
	Response_statuses = {
		pending: 0,
		accepted: 1,
		declined: 2
	}

	belongs_to :user
	belongs_to :meeting


	belongs_to :arriving_travel, class_name: 'Travel', foreign_key: 'arriving_travel_id'
	belongs_to :leaving_travel, class_name: 'Travel', foreign_key: 'leaving_travel_id'

	validates :response_status, presence: true
	validates_inclusion_of :is_admin, :in => [true, false]
	validates_inclusion_of :is_consistent, :in => [true, false]

	validate :response_status_correctness

	private
	def response_status_correctness
		if response_status.blank?
			return
		end
		unless Response_statuses.values.include? response_status
			errors.add(:response_status, "must be one between #{Response_statuses.values}")
		end
	end
end
