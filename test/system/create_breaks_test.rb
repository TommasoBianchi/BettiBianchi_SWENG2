require "application_system_test_case"

class CreateBreaksTest < ApplicationSystemTestCase
  
	test "login and create a break" do
		login_test_user

		visit add_break_path

		fill_in "name", with: "Test break"
		fill_in "day_of_the_week", with: "Thursday"
		fill_in "start_time_slot", with: "12:00pm"
		fill_in "default_time", with: "1:00pm"
		fill_in "end_time_slot", with: "2:00pm"
		fill_in "duration", with: "30"

		find('input[name="commit"]').click	
	end

end
