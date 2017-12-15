class MeetingParticipation < ApplicationRecord
  # This should be a constant
  Response_statuses = {
    pending: 0,
    accepted: 1,
    declined: 2
  }.freeze

  belongs_to :user
  belongs_to :meeting

  belongs_to :arriving_travel, class_name: 'Travel', foreign_key: 'arriving_travel_id', required: false
  belongs_to :leaving_travel, class_name: 'Travel', foreign_key: 'leaving_travel_id', required: false

  validates :response_status, presence: true
  validates_inclusion_of :is_admin, in: [true, false]
  validates_inclusion_of :is_consistent, in: [true, false]

  validate :response_status_correctness

  def conflicting_meeting_participations
    return MeetingParticipation.where('id in 
      ((select meeting_participation_1_id from meeting_participation_conflicts where meeting_participation_2_id = :id) 
        union 
      (select meeting_participation_2_id from meeting_participation_conflicts where meeting_participation_1_id = :id))', {id: self.id})
  end

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
