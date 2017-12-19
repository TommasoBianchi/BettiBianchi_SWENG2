class ComputedBreak < ApplicationRecord
	belongs_to :user	
	belongs_to :break

	validates :computed_time, :start_time_slot, :end_time_slot, :name, :duration, presence: true
	validates_inclusion_of :is_doable, in: [true, false]

	validate :date_consistency

	private
	def date_consistency
		if [computed_time.blank?, start_time_slot.blank?, end_time_slot.blank?].any?
			return
		end
		if computed_time < start_time_slot or computed_time > end_time_slot
			errors.add(:computed_time, 'must be between start_time_slot and end_time_slot')
		end
	end
end
