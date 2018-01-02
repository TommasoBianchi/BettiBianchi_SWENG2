require "application_system_test_case"

class NavigationsTest < ApplicationSystemTestCase
  
	test "navigate to all pages" do
		
		# Login
		login_test_user

		# Navigate to all the main pages of the application (via the navbar)
		find('a[title=Profile]').click
		find('a[title=Calendar]').click
		find('a[title=Settings]').click
		find('a[title=Notifications]').click

		find('a[title=create-meeting]').click
		find('a[title=calendar-day]').click
		find('a[title=calendar-week]').click
		find('a[title=calendar-month]').click
	end

end
