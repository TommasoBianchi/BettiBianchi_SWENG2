require 'test_helper'

class UserTest < ActiveSupport::TestCase

	test "primary email in emails" do
		User.all.each do |user|
			assert user.emails.where(id: user.primary_email.id).count == 1
		end
	end

	test "always at least one default location" do
		User.all.each do |user|
			assert user.default_locations.count > 0
		end
	end

  # test "the truth" do
  #   assert true
  # end
end
