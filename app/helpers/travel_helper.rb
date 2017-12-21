module TravelHelper

	def self.shortest_path(start_location, end_location, travel_mean = :driving, departure_time = nil, arrival_time = nil)
		# If the application needs to scale to more countries in different timezones these values needs to be stored
		# somehow on the db (maybe alongside the user's data) and NOT be constant values here
		region = 'it'
		language = 'it'
		time_zone_offset = 60 * 60

		url = "#{BaseURL}?origin=#{start_location.latitude},#{start_location.longitude}"
		url += "&destination=#{end_location.latitude},#{end_location.longitude}&key#{GoogleAPIKey}"
		url += "&mode=#{TravelMeansToTravelModes[travel_mean]}"
		url += "&region=#{region}&language=#{language}"
		url += "&departure_time=#{departure_time.to_i - time_zone_offset}" if departure_time
		url += "&arrival_time=#{arrival_time.to_i - time_zone_offset}" if arrival_time

		puts url
		
		response = RestClient::Request.execute(method: :get, url: url)
		json_response = JSON.parse(response)

		if json_response['status'] != 'OK'
			if json_response['status'] == 'OVER_QUERY_LIMIT'
				# Wait a couple of seconds before retry to avoid upsetting google
				sleep 2
				
				return shortest_path(start_location, end_location, travel_mean, departure_time, arrival_time)
			end
			# raise error?
			puts json_response['status']
			return nil
		end

		legs = json_response['routes'][0]['legs'][0]
		duration = legs['duration']['value']	# in seconds
		distance = legs['distance']['value']	# in meters
		start_time = legs['departure_time']['value'] if legs['departure_time']	# this is not always present
		end_time = legs['arrival_time']['value'] if legs['arrival_time']	# this is not always present
		steps = legs['steps']

		formatted_steps = []

		steps.each do |step|
			formatted_step = {
				duration: step['duration']['value'],
				distance: step['distance']['value'],
				from: {
					lat: step['start_location']['lat'],
					lng: step['start_location']['lng']
				},
				to: {
					lat: step['end_location']['lat'],
					lng: step['end_location']['lng']
				},
				details: step['html_instructions'],
				travel_mean: TravelModesToTravelMeans[step['travel_mode']]
			}

			# Add arrival/departure time/stop for transit

			if step['travel_mode'] == "TRANSIT"
				formatted_step[:departure_stop] = step['transit_details']['departure_stop']['name']
				formatted_step[:departure_time] = step['transit_details']['departure_time']['text']
				formatted_step[:arrival_stop] = step['transit_details']['arrival_stop']['name']
				formatted_step[:arrival_time] = step['transit_details']['arrival_time']['text']
			end

			formatted_steps.push(formatted_step)
		end

		result = {
			duration: duration,
			distance: distance,
			steps: formatted_steps
		}

		result[:start_time] = Time.at(start_time + time_zone_offset) if start_time
		result[:end_time] = Time.at(end_time + time_zone_offset) if end_time

		return result
	end

	def self.best_travel(from_location, to_location, user, departure_time = DateTime.now, arrival_time = nil)
		weighted_list = []		
		preference_list = user.preference_list.chars.map {|c| Travel::Travel_means.keys[c.to_i]}

		preference_list.each do |travel_mean|
			path = shortest_path(from_location, to_location, travel_mean, departure_time, arrival_time)

			next unless path

			path[:travel_mean] = travel_mean
			unless path[:start_time]
				path[:start_time] = if departure_time then departure_time else (arrival_time - path[:duration].seconds) end
			end
			unless path[:end_time]
				path[:end_time] = if arrival_time then arrival_time else (departure_time + path[:duration].seconds) end
			end

			# probably not needed because this info is already in the steps
			# TODO: remove if really not needed
=begin
			if travel_mean == :public_transportation
				path[:start_time] = path[:steps].first[:departure_time]
				path[:end_time] = path[:steps].last[:arrival_time]
			end
=end

			# Constraint satisfaction
			constraint_violated = false
			user.constraints.where(travel_mean: Travel::Travel_means[travel_mean]).each do |constraint|
				if constraint.check_path(path)
					constraint_violated = true
					break
				end
			end
			
			next if constraint_violated

			path[:weighted_duration] = path[:duration] + weighted_list.length * (60 * 15)	# 15 minutes disadvantage per preference list position
			puts "Travel_mean = #{path[:travel_mean]}, Duration = #{path[:duration]}, Weighted_duration = #{path[:weighted_duration]}"
			weighted_list.push path
		end

		if weighted_list.length == 0
			return nil 
		end

		weighted_list = weighted_list.sort_by {|el| el[:weighted_duration]}

		return weighted_list.first
	end

	private

	GoogleAPIKey = 'AIzaSyDba6PxTVz-07hIVjksboJ4AEkOP2WeuAs'

	TravelMeansToTravelModes = {
		walking: 'walking',
		driving: 'driving',
		biking: 'bicycling',
		public_transportation: 'transit'
	}

	TravelModesToTravelMeans = {
		'DRIVING' => :driving,
		'WALKING' => :walking,
		'BICYCLING' => :biking,
		'TRANSIT' => :public_transportation
	}

	BaseURL = 'https://maps.googleapis.com/maps/api/directions/json'
end