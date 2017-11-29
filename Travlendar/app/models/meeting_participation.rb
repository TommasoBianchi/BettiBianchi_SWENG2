class MeetingParticipation < ApplicationRecord
  belongs_to :user
  belongs_to :meeting

  has_one :arriving_travel, class_name => "travel"
  has_one :leaving_travel, class_name => "travel"
end
