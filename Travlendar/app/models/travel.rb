class Travel < ApplicationRecord
  belongs_to :meeting_participation
  has_many :travel_steps
end
