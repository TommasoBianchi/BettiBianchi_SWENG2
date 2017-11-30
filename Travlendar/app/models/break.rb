class Break < ApplicationRecord
	belongs_to :user

	validates :default_time, :start_time_slot, :end_time_slot, :day_of_the_week, :name, :duration, presence: true

	validate :date_consistency
	validate :day_of_the_week_correctness

	private
	def date_consistency
		if [default_time.blank?, start_time_slot.blank?, end_time_slot.blank?].any?
			errors.add(:break, 'default_time, start_time_slot and end_time_slot must be present')
			return
		end
		if default_time < start_time_slot or default_time > end_time_slot
			errors.add(:default_time, 'must be between start_time_slot and end_time_slot')
		end
	end

	def day_of_the_week_correctness
		if day_of_the_week.blank?
			errors.add(:day_of_the_week, 'must be present')
			return
		end
		if day_of_the_week < 0 or day_of_the_week > 6
			errors.add(:day_of_the_week, 'must be before 0 and 6')
		end
	end
end