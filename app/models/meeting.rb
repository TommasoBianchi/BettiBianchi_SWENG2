class Meeting < ApplicationRecord
  belongs_to :location
  has_many :meeting_participations
  has_many :users, through: :meeting_participations

  validates :start_date, :end_date, :title, presence: true

  validate :date_consistency

  private
	def date_consistency
		if [start_date.blank?, end_date.blank?].any?
			return
		end
		if start_date > end_date
			errors.add(:end_date, 'must be after start_date')
		end
	end
end
