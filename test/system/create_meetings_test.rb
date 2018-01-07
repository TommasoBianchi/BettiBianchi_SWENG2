require "application_system_test_case"

class CreateMeetingsTest < ApplicationSystemTestCase
  
	test "create a meeting" do
		login_test_user

		title = "_system_test_meeting_#{rand(1..10000000)}"
		date = DateTime.tomorrow.strftime("%Y/%m/%d")
		start_time = "1:00pm"
		end_time = "3:00pm"
		location = "Via Milano Varese"

		create_meeting title, date, start_time, end_time, location

		# The application should redirect me to the calendar page of the day of the meeting
		assert (current_path == "/calendar/day/#{DateTime.tomorrow.strftime("%Y/%-m/%-d")}")
		sleep 10 # To give time to schedule the meeting and the travels properly
		# Reload the page to see the scheduled meeting
		visit current_path
		assert (find('.meeting-title').text == title)
	end

	test "create two overlapping meetings should generate a warning" do
		login_test_user

		title1 = "_system_test_meeting_#{rand(1..10000000)}"
		title2 = "_system_test_meeting_#{rand(1..10000000)}"
		date = DateTime.tomorrow.strftime("%Y/%m/%d")

		create_meeting title1, date, "12:00pm", "4:00pm", "Via Ponzio Milano"
		create_meeting title2, date, "3:00pm", "6:00pm", "Porta Genova"

		sleep 20 # To give time to schedule the meeting and the travels properly
		
		visit current_path # Reload the page to see the scheduled meeting
		find('a[title=Notifications]').click
		find('.meeting-title', :text => title1)
	end

	private
	def create_meeting(title, date, start_time, end_time, location)
		find('a[title=create-meeting]').click

		fill_in "title", with: title
		fill_in "abstract", with: "abstract"
		fill_in "date", with: date
		fill_in "start_date", with: start_time
		fill_in "end_date", with: end_time

		fill_in "location", with: location
		find('.pac-item:first-child').click
		sleep 1 # To give time to google to fill in the autocomplete
		find('input[name="commit"]').click
	end

end
