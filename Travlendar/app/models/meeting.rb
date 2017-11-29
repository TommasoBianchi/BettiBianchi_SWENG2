class Meeting < ApplicationRecord
  belongs_to :location
  has_many :meeting_participations
  has_many :users, through: :meeting_participations
end
