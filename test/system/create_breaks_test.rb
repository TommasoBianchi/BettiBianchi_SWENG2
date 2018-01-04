require "application_system_test_case"

class CreateBreaksTest < ApplicationSystemTestCase
  
	test "login and create a break" do
		login_test_user

		find('a[title=Settings]').click
		find('.title-add-container', :text => "Breaks").find('a img').click

		title = "Test break #{rand(1..100000000)}"
		fill_in "name", with: title
		fill_in "day_of_the_week", with: "Thursday"
		fill_in "start_time_slot", with: "12:00pm"
		fill_in "default_time", with: "1:00pm"
		fill_in "end_time_slot", with: "2:00pm"
		fill_in "duration", with: "30"

		find('input[name="commit"]').click	

		find('a[title=Settings]').click

		find('.break .default-location-name', :text => title)
	end

	test "create a break and a partially overlapping meeting" do 
		#Login
		login_test_user

		# Create a break
		find('a[title=Settings]').click
		find('.title-add-container', :text => "Breaks").find('a img').click

		title = "Test break #{rand(1..100000000)}"
		fill_in "name", with: title
		fill_in "day_of_the_week", with: "Thursday"
		fill_in "start_time_slot", with: "12:00pm"
		fill_in "default_time", with: "1:00pm"
		fill_in "end_time_slot", with: "2:00pm"
		fill_in "duration", with: "30"

		find('input[name="commit"]').click	

		# Create a meeting
		find('a[title=create-meeting]').click

		fill_in "title", with: "New Test Meeting"
		fill_in "abstract", with: "abstract"
		fill_in "date", with: (DateTime.new(2018, 1, 4) + 50.weeks).strftime("%Y/%-m/%-d")
		fill_in "start_date", with: "11:00am"
		fill_in "end_date", with: "1:05pm"

		fill_in "location", with: "Viale Abruzzi Milano"
		find('.pac-item:first-child').click
		sleep 1 # To give time to google to fill in the autocomplete
		find('input[name="commit"]').click
		sleep 10 # To give time to schedule the meeting and the travels properly

		visit current_path # Reload the page to see the meeting
		find('.break-name', :text => title)
	end

end
