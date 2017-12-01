class MeetingParticipation < ApplicationRecord
	# This should be a constant
	Response_statuses = {
		pending: 0,
		accepted: 1,
		declined: 2
	}

	belongs_to :user
	belongs_to :meeting

	has_one :arriving_travel, class_name: "travel"
	has_one :leaving_travel, class_name: "travel"

	validates :is_admin, :is_consistent, :response_status

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
