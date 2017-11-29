class Meeting < ApplicationRecord
  belongs_to :location
  has_many :meeting_participations
end
