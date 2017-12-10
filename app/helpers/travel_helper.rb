module TravelHelper

	def self.shortest_path(start_location, end_location, travel_mean = :driving, departure_time = nil, arrival_time = nil)
		url = "#{BaseURL}?origin=#{start_location}&destination=#{end_location}&key#{GoogleAPIKey}"
		url += "&mode=#{TravelMeansToTravelModes[travel_mean]}"
		url += "&region=it"
		url += "&departure_time=#{departure_time.to_i}" if departure_time
		url += "&arrival_time=#{arrival_time.to_i}" if arrival_time
		
		response = RestClient::Request.execute(method: :get, url: url)
		json_response = JSON.parse(response)

		if json_response['status'] != 'OK'
			# raise error?
			return json_response
		end

		legs = json_response['routes'][0]['legs'][0]
		duration = legs['duration']['value']	# in seconds
		distance = legs['distance']['value']	# in meters
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

		return {
			duration: duration,
			distance: distance,
			steps: formatted_steps
		}
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