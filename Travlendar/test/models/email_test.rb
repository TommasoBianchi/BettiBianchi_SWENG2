require 'test_helper'

class EmailTest < ActiveSupport::TestCase

	test "is a valid email" do
		reg_ex_pattern = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
		Email.all.each do |email|
			reg_ex_pattern.match?(email.email)
		end
	end

	test "no unowned emails" do
		Email.all.each do |email|
			assert_not_nil User.find(email.user_id)
		end
	end

end
