require "application_system_test_case"

class SignupsTest < ApplicationSystemTestCase

	test "signup then login" do 
		
		# Signup
		res = signup

		# Logout
		logout

		# Login again (via nickname)
		login(nickname: res[:nickname], password: res[:password])
	end

end
