require "application_system_test_case"

class SignupsTest < ApplicationSystemTestCase

	test "signup then login" do 
		visit homepage_path

		# Signup
		fill_in "emailField", with: "#{rand(1..1000000000)}@test.com"
		fill_in "homepage_password", with: "0000"

		find('input[name="signup"]').click

		# Post registration information
		fill_in "password", with: "0000"
		fill_in "password_confirmation", with: "0000"
		fill_in "name", with: "System"
		fill_in "surname", with: "Test"
		nickname = "#{rand(1..1000000000)}ST"
		fill_in "nickname", with: nickname

		find('input[name="commit"]').click
	
		# Insert first default location
		fill_in "name", with: "First default location"
		fill_in "dl_date", with: "Monday"
		fill_in "meeting_start_time", with: "7:00am"
		fill_in "pac-input", with: "Via Milano Milano"
		find('.pac-item:first-child').click
		sleep 1 # To give time to google to fill in the autocomplete
		find('input[name="commit"]').click

		# Logout
		find('a[title=Profile]').click
		find('.logout').click

		# Login again (via nickname)
		fill_in "emailField", with: nickname
		fill_in "homepage_password", with: "0000"

		find('input[name="login"]').click
	end

end
