require 'test_helper'

class TravelTest < ActiveSupport::TestCase

	test "no travels between default locations" do
		Travel.all.each do |travel|
			assert !(travel.starting_location_dl and travel.ending_location_dl), "Failed travel #{travel.id}"
		end
	end

	test "same user start and end" do
		Travel.all.each do |travel|
			starting_user = if travel.starting_location_dl.blank? then travel.starting_location_meeting.user else travel.starting_location_dl.user end
			ending_user = if travel.ending_location_dl.blank? then travel.ending_location_meeting.user else travel.ending_location_dl.user end

			assert (starting_user == ending_user), "Failed travel #{travel.id}"
		end
	end

	test "starting point consistency" do
			Travel.all.each do |travel|
				assert (true or travel.starting_location_dl.blank? != travel.starting_location_meeting.blank? or 
						!travel.starting_location_meeting.is_consistent or
						travel.starting_location_meeting.response_status == 2), "Failed travel #{travel.id}"
			end
	end

	test "ending point consistency" do
			Travel.all.each do |travel|
				assert (travel.ending_location_dl.blank? != travel.ending_location_meeting.blank? or 
						!travel.ending_location_meeting.is_consistent or
						travel.ending_location_meeting.response_status == 2), "Failed travel #{travel.id}"
			end
	end

	# test "the truth" do
	#   assert true
	# end
end
