require 'test_helper'

class IncompleteUserTest < ActiveSupport::TestCase

	test "not incomplete user with an existing email" do
		IncompleteUser.all.each do |incomplete_user|
			assert Email.where(email: incomplete_user.email).count == 0
		end
	end

	test "do not exist two incomplete user with the same email" do
		IncompleteUser.all.each do |incomplete_user|
			assert IncompleteUser.where(email: incomplete_user.email).count == 1
		end
	end
end
