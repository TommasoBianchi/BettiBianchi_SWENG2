class Subject < ApplicationRecord
  has_many :operators
  has_many :values
end
