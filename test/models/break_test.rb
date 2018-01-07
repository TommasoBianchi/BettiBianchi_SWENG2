require 'test_helper'

class BreakTest < ActiveSupport::TestCase
	test "start time before end time" do
		Break.all.each do |br|
			assert br.start_time_slot < br.end_time_slot
			assert br.start_time_slot <= br.default_time
			assert br.default_time <= br.end_time_slot
			assert br.end_time_slot - br.start_time_slot >= br.duration
		end
	end

	test "real day of the week" do
		Break.all.each do |br|
			assert br.day_of_the_week <= 6
			assert br.day_of_the_week >= 0
		end
	end
end
