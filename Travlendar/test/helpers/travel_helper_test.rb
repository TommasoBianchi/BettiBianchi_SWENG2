class TravelHelperTest < ActionView::TestCase

	test "shortest path" do
		start_location = Location.first
		end_location = Location.last
		departure_time = DateTime.new(2018, 3, 1, 12, 30)

		Travel::Travel_means.keys.each do |travel_mean|
			result = TravelHelper.shortest_path start_location, end_location, travel_mean, departure_time
			next unless result

			if result[:start_time]
				assert (result[:start_time] == departure_time) unless travel_mean == :public_transportation
				# Public transportation travels may actually start slightly after the requested departure 
				# time as they should stick to public transportation schedules
				assert (result[:start_time] >= departure_time) if travel_mean == :public_transportation
			end
			assert (result[:distance] >= great_circle_distance(start_location.latitude, start_location.longitude,
													  end_location.latitude, end_location.longitude))
		end
	end

	test "best travel" do
		start_location = Location.first
		end_location = Location.last
		departure_time = DateTime.new(2018, 3, 15, 10)
		user = User.last

		result = TravelHelper.best_travel start_location, end_location, user, departure_time

		assert user.preference_list.chars.map {|c| Travel::Travel_means.keys[c.to_i]}.include?(result[:travel_mean])
		assert (result[:distance] >= great_circle_distance(start_location.latitude, start_location.longitude,
													  end_location.latitude, end_location.longitude))
		assert result[:start_time] == departure_time # This may not take into account correctly public transportation
	end

	private
	# Implementation of the Haversine formula adapted from https://stackoverflow.com/a/21623206
	def great_circle_distance(lat1, lon1, lat2, lon2)
    	p = 0.017453292519943295     #Pi/180
    	a = 0.5 - Math.cos((lat2 - lat1) * p)/2 + Math.cos(lat1 * p) * Math.cos(lat2 * p) * (1 - Math.cos((lon2 - lon1) * p)) / 2
    	result = 12742 * Math.asin(Math.sqrt(a)) #2*R*asin...
    	return result * 1000 # Convert result from km to m
    end
end