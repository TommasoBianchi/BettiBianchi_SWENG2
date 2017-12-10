class Travel < ApplicationRecord
  # This should be a constant
  Travel_means = {
    walking: 0,
    driving: 1,
    public_transportation: 2,
    biking: 3
  }.freeze

  has_many :travel_steps

  belongs_to :starting_location_dl, class_name: 'DefaultLocation', foreign_key: 'starting_location_dl_id', required: false
  has_one :starting_location_meeting, class_name: 'MeetingParticipation', required: false
  belongs_to :ending_location_dl, class_name: 'DefaultLocation', foreign_key: 'ending_location_dl_id', required: false
  has_one :ending_location_meeting, class_name: 'MeetingParticipation', required: false

  before_validation do
    if starting_location_dl.blank? && starting_location_meeting.blank?
      self.starting_location_dl_id = ending_location_dl_id
    end

    self.ending_location_dl_id = starting_location_dl_id if ending_location_dl.blank? && ending_location_meeting.blank?
  end

  validates :start_time, :end_time, :distance, :travel_mean, presence: true

  validate :date_consistency
  validate :travel_mean_correctness

  validate :starting_point_consistency
  validate :ending_point_consistency
  validate :same_user_starting_ending_point, if: '(starting_location_dl.present? || starting_location_meeting.present?) && (ending_location_dl.present? || ending_location_meeting.present?)'

  def get_duration_integer
    ((end_time - start_time) * 24 * 60).to_i
  end

  def get_user
    if starting_location_dl.present?
      starting_location_dl.user
    elsif ending_location_dl.present?
      ending_location_dl.user
    elsif starting_location_meeting.present?
      starting_location_meeting.user
    elsif ending_location_meeting.present?
      ending_location_meeting.user
    end
  end

  private

  def date_consistency
    return if [start_time.blank?, end_time.blank?].any?
    errors.add(:start_time, 'must be after end_time') if start_time > end_time
  end

  def travel_mean_correctness
    return if travel_mean.blank?
    unless Travel_means.values.include? travel_mean
      errors.add(:travel_mean, "must be one between #{Travel_means.values}")
    end
  end

  def starting_point_consistency
    if starting_location_dl.blank? && starting_location_meeting.blank?
      errors.add(:starting_location_dl, ' at least one starting point must be present')
      errors.add(:starting_location_meeting, ' at least one starting point must be present')
    end
  end

  def ending_point_consistency
    if ending_location_dl.blank? && ending_location_meeting.blank?
      errors.add(:ending_location_dl, ' at least one ending point must be present')
      errors.add(:ending_location_meeting, ' at least one ending point must be present')
    end
  end

  def same_user_starting_ending_point
    starting_user = if starting_location_dl.blank?
                      starting_location_meeting.user
                    else
                      starting_location_dl.user
                    end

    ending_user = if ending_location_dl.blank?
                    ending_location_meeting.user
                  else
                    ending_location_dl.user
                  end

    unless starting_user = ending_user
      errors.add(:starting_location_dl, ' the starting point and endign point must belongs to the same user')
      errors.add(:starting_location_meeting, ' the starting point and endign point must belongs to the same user')
      errors.add(:ending_location_dl, ' the starting point and endign point must belongs to the same user')
      errors.add(:ending_location_meeting, ' the starting point and endign point must belongs to the same user')
    end
  end
end
