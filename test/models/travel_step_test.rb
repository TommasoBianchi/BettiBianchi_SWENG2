require 'test_helper'

class TravelStepTest < ActiveSupport::TestCase

	test "start and end time consistency" do
		TravelStep.all.each do |travel_step|
			assert travel_step.start_time <= travel_step.end_time
		end
	end

	test "travel step start time consistency with its travel" do
		TravelStep.all.each do |travel_step|
			unless Travel.find(travel_step.travel_id).start_time <= travel_step.start_time
				puts(travel_step.id)
				puts(Travel.find(travel_step.travel_id).start_time)
				puts(travel_step.start_time)
			end
			assert Travel.find(travel_step.travel_id).start_time <= travel_step.start_time
		end
	end

	test "travel step end time consistency with its travel" do
		TravelStep.all.each do |travel_step|
			unless  Travel.find(travel_step.travel_id).end_time >= travel_step.end_time
				puts(travel_step.id)
				puts(Travel.find(travel_step.travel_id).end_time)
				puts(travel_step.end_time)
			end
			assert Travel.find(travel_step.travel_id).end_time >= travel_step.end_time
		end
	end
end
