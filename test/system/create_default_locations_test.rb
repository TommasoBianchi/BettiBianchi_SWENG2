require "application_system_test_case"

class CreateDefaultLocationsTest < ApplicationSystemTestCase
  
	test "create a default location" do
		#Login 
		login_test_user

		find('a[title=Settings]').click
		find('.title-add-container', :text => "Default Locations").find('a img').click

		name = "Test default location #{rand(1..100000000)}"
		fill_in "name", with: name
		fill_in "day_of_the_week", with: "Wednesday"
		fill_in "starting_hour", with: "7:00am"
		fill_in "pac-input", with: "Via Padova Milano"
		find('.pac-item:first-child').click
		sleep 1 # To give time to google to fill in the autocomplete
		find('input[name="commit"]').click

		find('a[title=Settings]').click
		find('.default-location .default-location-name', :text => name)
	end

end
