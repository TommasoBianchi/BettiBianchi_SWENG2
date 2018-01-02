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

  test "unique_nickname" do
		User.all.each do |user|
			assert User.where(nickname: user.nickname).count == 1
		end
	end

	test "correct_phone_number_and_pref_list" do
		is_number = /^[0-9]+$/
		User.all.each do |user|
			assert is_number.match?(user.phone_number) || user.phone_number == nil
			assert user.preference_list.length > 0
		end
	end

end
