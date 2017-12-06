class MeetingParticipation < ApplicationRecord
  # This should be a constant
  Response_statuses = {
    pending: 0,
    accepted: 1,
    declined: 2
  }.freeze

  belongs_to :user
  belongs_to :meeting

  belongs_to :arriving_travel, class_name: 'Travel', foreign_key: 'arriving_travel_id'
  belongs_to :leaving_travel, class_name: 'Travel', foreign_key: 'leaving_travel_id'

  validates :response_status, presence: true
  validates_inclusion_of :is_admin, in: [true, false]
  validates_inclusion_of :is_consistent, in: [true, false]

  validate :response_status_correctness

  def get_name_surname
    user.name + ' ' + user.surname
  end

  private

  def response_status_correctness
    return if response_status.blank?
    unless Response_statuses.values.include? response_status
      errors.add(:response_status, "must be one between #{Response_statuses.values}")
    end
  end
end
