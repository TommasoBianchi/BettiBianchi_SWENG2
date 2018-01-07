require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
	driven_by :selenium, using: :chrome, screen_size: [1366, 768]

	def signup(email = "#{rand(1..1000000000)}@test.com", nickname = "#{rand(1..1000000000)}ST", password = "0000")
		visit homepage_path

		# Signup
		fill_in "emailField", with: email
		fill_in "homepage_password", with: password

		find('input[name="signup"]').click

		# Post registration information
		fill_in "password", with: password
		fill_in "password_confirmation", with: password
		fill_in "name", with: "System"
		fill_in "surname", with: "Test"
		fill_in "nickname", with: nickname

		find('input[name="commit"]').click
	
		# Insert first default location
		fill_in "name", with: "First default location"
		fill_in "day_of_the_week", with: "Monday"
		fill_in "starting_hour", with: "7:00am"
		fill_in "pac-input", with: "Via Milano Milano"
		find('.pac-item:first-child').click
		sleep 1 # To give time to google to fill in the autocomplete
		find('input[name="commit"]').click

		return {email: email, nickname: nickname, password: password}
	end

	def login(email: nil, nickname: nil, password: nil)
		visit homepage_path

		fill_in "emailField", with: (nickname or email)
		fill_in "homepage_password", with: password

		find('input[name="login"]').click
	end

	def login_test_user
		login email: Test_user_email, nickname: Test_user_nickname, password: Test_user_password

		# If login fails, then register the test user
		if current_path == "/"
			signup Test_user_email, Test_user_nickname, Test_user_password
			login email: Test_user_email, nickname: Test_user_nickname, password: Test_user_password
		end
	end

	def logout
		find('a[title=Profile]').click
		find('.logout').click
	end

	# Make sure puma server runs with more than one thread available
	Capybara.register_server :rails_puma_custom do |app, port, host|
		Rack::Handler::Puma.run(app, Port: port, Threads: "0:5")
	end
	Capybara.server = :rails_puma_custom

	private
	Test_user_email = "_test_user_@test.travlendar.com"
	Test_user_password = "000000"
	Test_user_nickname = "_test_user_"
end
