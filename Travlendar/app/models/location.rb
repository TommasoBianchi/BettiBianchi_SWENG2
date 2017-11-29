class Location < ApplicationRecord
  has_many :default_locations
  has_many :meetings
end
