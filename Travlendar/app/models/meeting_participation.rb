class MeetingParticipation < ApplicationRecord
  belongs_to :user
  belongs_to :meeting

  belongs_to :arriving_travel, class_name: 'Travel', foreign_key: 'arriving_travel_id'
  belongs_to :leaving_travel, class_name: 'Travel', foreign_key: 'leaving_travel_id'
end
