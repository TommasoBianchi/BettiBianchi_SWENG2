require 'test_helper'

class LocationTest < ActiveSupport::TestCase

	test "do not exist two different locations in the same lat-lang" do
		Location.all.each do |location|
			assert Location.where(latitude: location.latitude, longitude: location.longitude).count == 1
		end
	end

	test "no locations without a def location or a meeting" do
		Location.all.each do |location|
			assert Meeting.where(location: location).count + DefaultLocation.where(location: location).count > 0
		end
	end

	test "latitude and longitude consistency" do
		Location.all.each do |location|
			assert location.latitude <= 180
			assert location.latitude >= -180
			assert location.longitude >= -180
			assert location.longitude <= 180
		end
	end

end
