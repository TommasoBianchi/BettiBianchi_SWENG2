class Subject < ApplicationRecord
  has_many :operators
  has_many :values

  validates :name, presence: true
end
