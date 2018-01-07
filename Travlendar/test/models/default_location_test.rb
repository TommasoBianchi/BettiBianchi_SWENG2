require 'test_helper'

class DefaultLocationTest < ActiveSupport::TestCase
	# test that a user doesn't have two default loactions starting at the same time

	test "consistency of day of the week" do
		DefaultLocation.all.each do |dl|
			assert dl.day_of_the_week <= 6
			assert dl.day_of_the_week >= 0
		end
	end

	test "no def locations without location" do
		DefaultLocation.all.each do |dl|
			assert Location.all.include?(dl.location)
		end
	end
end
