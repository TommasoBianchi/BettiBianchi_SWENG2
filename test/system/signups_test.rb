require "application_system_test_case"

class SignupsTest < ApplicationSystemTestCase

	test "signup then login" do 
		visit homepage_path

		fill_in "emailField", with: "#{rand(1..1000000000)}@test.com"
		fill_in "homepage_password", with: "0000"

		find('input[name="signup"]').click

		# Post registration information
		fill_in "password", with: "0000"
		fill_in "name", with: "System"
		fill_in "surname", with: "Test"
		fill_in "nickname", with: "#{rand(1..1000000000)}ST"

		find('input[name="commit"]').click

		visit calendar_day_path 2017, 12, 25

		sleep 5

		delete "/logout"

		sleep 5
	end

end
