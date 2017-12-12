module MeetingHelper
  # new_meeting = {start_date, end_date, location}
  def self.insert_meeting(new_meeting, user)
    user_meetings = user.meeting_participations.joins(:meeting)
    # These are actually MeetingParticipation
    overlapping_meetings = user_meetings.where(meetings: { start_date: new_meeting.start_date..new_meeting.end_date })
                                        .or(user_meetings.where(meetings: { end_date: new_meeting.start_date..new_meeting.end_date }))
    overlapping_meetings.each do |mp|
      mp.is_consistent = false
      new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
      new_meeting[:conflict_set].push mp.meeting_id
    end

    unless overlapping_meetings.empty?
      new_meeting[:is_consistent] = false
      return new_meeting
    end

    defloc_before = user.get_last_default_location_before new_meeting.start_date
    defloc_after = user.get_first_location_after new_meeting.end_date

    arriving_travel = TravelHelper.best_travel(defloc_before.location, new_meeting.location, user)
    leaving_travel = TravelHelper.best_travel(new_meeting.location, defloc_after.location, user)

    # These are actually MeetingParticipation
    before_meeting = user_meetings.where(meetings: { is_consistent: true })
                                  .where('`meetings`.`end_date` < ?', new_meeting.start_date).order('meetings.end_date').last
    after_meeting = user_meetings.where(meetings: { is_consistent: true })
                                 .where('`meetings`.`start_date` > ?', new_meeting.end_date).order('meetings.start_date').first

    if !before_meeting.nil? && (arriving_travel.duration > (new_meeting.start_date - before_meeting.leaving_travel.end_time))
      arriving_travel = TravelHelper.best_travel(before_meeting.meeting.location, new_meeting.location, user)
      if arriving_travel.duration > (new_meeting.start_date - before_meeting.meeting.end_date)
        new_meeting[:is_consistent] = false
        before_meeting.is_consistent = false
        new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
        new_meeting[:conflict_set].push before_meeting.meeting_id
        return new_meeting
      else
        new_meeting[:link_before_meeting] = true
      end
    end

    if !after_meeting.nil? && (leaving_travel.duration > (after_meeting.arriving_travel.start_time - new_meeting.end_date))
      leaving_travel = TravelHelper.best_travel(new_meeting.location, after_meeting.meeting.location, user)
      if leaving_travel.duration > (after_meeting.meeting.start_date - new_meeting.end_date)
        new_meeting[:is_consistent] = false
        after_meeting.is_consistent = false
        new_meeting[:conflict_set] = [] unless new_meeting[:conflict_set]
        new_meeting[:conflict_set].push after_meeting.meeting_id
        return new_meeting
      else
        new_meeting[:link_after_meeting] = true
      end
    end

    /overlapping_breaks := all breaks of user that overlap with new_meeting and its travels

		for all break in overlapping_breaks do
			UPDATE_BREAK(break, new_meeting ,arriving_travel, leaving_travel)
			add (new_meeting, break) to break_overlap_set
		end for/

    new_meeting[:is_consistent] = true
    new_meeting[:arriving_travel] = arriving_travel
    new_meeting[:leaving_travel] = leaving_travel
  end

  def self.get_autocomplete_location(location)
    url = "#{BaseURL}?input=#{location}&types=geocode&key#{GoogleAPIKey}"

    response = RestClient::Request.execute(method: :get, url: url)
    json_response = JSON.parse(response)

    if json_response['status'] != 'OK'
      # raise error?
      return json_response
    end

    all_predictions = json_response['predictions']
    list_locations = []
    all_predictions.each do |prediction|
      location = {
        description: prediction['description'],
        place_id: prediction['place_id']
      }
      list_locations.push(location)
    end

    list_locations
  end

  GoogleAPIKey = 'AIzaSyDba6PxTVz-07hIVjksboJ4AEkOP2WeuAs'.freeze

  BaseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'.freeze
end
