class TravelStep < ApplicationRecord
  # This should be a constant
  Travel_means = {
    walking: 0,
    driving: 1,
    public_transportation: 2,
    biking: 3
  }.freeze

  belongs_to :travel

  validates :start_time, :end_time, :distance, :travel_mean, presence: true

  validate :date_consistency
  validate :travel_mean_correctness

  private

  def date_consistency
    return if [start_time.blank?, end_time.blank?].any?
    errors.add(:start_time, 'must be after end_time') if start_time > end_time
  end

  def travel_mean_correctness
    return if travel_mean.blank?
    unless Travel::Travel_means.values.include? travel_mean
      errors.add(:travel_mean, "must be one between #{Travel::Travel_means.values}")
    end
  end
end
