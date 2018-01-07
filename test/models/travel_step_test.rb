require 'test_helper'

class TravelStepTest < ActiveSupport::TestCase

	test "start and end time consistency" do
		TravelStep.all.each do |travel_step|
			assert travel_step.start_time <= travel_step.end_time
		end
	end

	test "travel step start time consistency with its travel" do
		TravelStep.all.each do |travel_step|
			# Keep 2 minutes of error tolerance because travels and travel steps may not be aligned with a precision of a second
			assert travel_step.travel.start_time - 2.minutes <= travel_step.start_time
		end
	end

	test "travel step end time consistency with its travel" do
		TravelStep.all.each do |travel_step|
			# Keep 2 minutes of error tolerance because travels and travel steps may not be aligned with a precision of a second
			assert travel_step.travel.end_time + 2.minutes >= travel_step.end_time
		end
	end
end
