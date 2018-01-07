require 'test_helper'

class UserTest < ActiveSupport::TestCase

	# test that each user can only have as much social user as the number of social
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

  test "unique nickname" do
		User.all.each do |user|
			assert User.where(nickname: user.nickname).count == 1
		end
	end

	test "correct phone number and pref list" do
		is_number = /^[0-9]+$/
		User.all.each do |user|
			assert is_number.match?(user.phone_number) || user.phone_number == nil
			assert user.preference_list.length > 0
		end
	end

	test "nobody can be contact of himself or have twice the same contact" do
		User.all.each do |user|
			contacts = user.contacts
			assert_not contacts.include?(user)
			assert contacts.length == contacts.uniq.length
		end
	end
end
