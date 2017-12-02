class Location < ApplicationRecord
  has_many :default_locations
  has_many :meetings

  validates :longitude, :latitude, presence: true

  validate :latlong_correctness

  private
  def latlong_correctness
	if [latitude.blank?, longitude.blank?].any?
		return
	end
	if latitude < -90 or latitude > 90
		errors.add(:latitude, 'must be between -90 and 90')
	end
	if longitude < -180 or longitude > 180
		errors.add(:longitude, 'must be between -180 and 180')
	end
  end
end
