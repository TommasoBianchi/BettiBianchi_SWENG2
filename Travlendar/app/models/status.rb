class Status < ApplicationRecord
	# This should be a constant
	Types = {
		auto_decline: 0
	}

	belongs_to :user

	validates :type, :from, :to, presence: true

	validate :type_correctness

	private 
	def response_status_correctness
		if type.blank?
			return
		end
		unless Type.values.include? type
			errors.add(:type, "must be one between #{Types.values}")
		end
	end
end
