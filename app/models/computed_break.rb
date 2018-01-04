class ComputedBreak < ApplicationRecord
	belongs_to :user
	belongs_to :break

	validates :computed_time, :start_time_slot, :end_time_slot, :name, :duration, presence: true
	validates_inclusion_of :is_doable, in: [true, false]

	validate :date_consistency

	# This method is used from the views to get the description of a computed break
	def get_description
		return "from " + start_time_slot.strftime("%H:%M") + " to: " + end_time_slot.strftime("%H:%M")
	end

	private

	# This method checks for the date consistency of a computed break
	def date_consistency
		if [computed_time.blank?, start_time_slot.blank?, end_time_slot.blank?].any?
			return
		end
		if computed_time < start_time_slot or computed_time > end_time_slot
			errors.add(:computed_time, 'must be between start_time_slot and end_time_slot')
		end
	end

end
