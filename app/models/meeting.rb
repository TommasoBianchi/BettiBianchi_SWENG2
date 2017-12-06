class Meeting < ApplicationRecord
  belongs_to :location
  has_many :meeting_participations
  has_many :users, through: :meeting_participations

  validates :start_date, :end_date, :title, presence: true

  validate :date_consistency

  def accepted_participants
    meeting_participations.where(response_status: 1)
  end

  private

  def date_consistency
    return if [start_date.blank?, end_date.blank?].any?
    errors.add(:end_date, 'must be after start_date') if start_date > end_date
  end
end
