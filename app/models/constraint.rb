class Constraint < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  belongs_to :operator
  belongs_to :value

  validates :travel_mean, presence: true
end
