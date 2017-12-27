require "application_system_test_case"

class SignupsTest < ApplicationSystemTestCase

	test "signup then login" do 
		visit homepage_path

		fill_in "emailField", with: "#{rand(1..1000000000)}@test.com"
		fill_in "homepage_password", with: "0000"

		find('input[name="signup"]').click

		# Post registration information
		fill_in "password", with: "0000"
		fill_in "password_confirmation", with: "0000"
		fill_in "name", with: "System"
		fill_in "surname", with: "Test"
		fill_in "nickname", with: "#{rand(1..1000000000)}ST"
		sleep 5
		find('input[name="commit"]').click
		sleep 5
		# Insert first default location
		fill_in "name", with: "First default location"
		fill_in "dl_date", with: "Monday"
		fill_in "meeting_start_time", with: "7:00am"
		fill_in "pac-input", with: "Via Milano Milano"
		sleep 5
		find('.pac-item').click
		sleep 5
		find('input[name="commit"]').click
		sleep 5

		delete "/logout"

		sleep 5
	end

end