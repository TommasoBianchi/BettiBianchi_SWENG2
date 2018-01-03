require 'test_helper'

class ConstraintTest < ActiveSupport::TestCase

	test "right operators and values" do
		Constraint.all.each do |constraint|
			assert constraint.operator.subject == constraint.subject
			assert constraint.value.subject == constraint.subject
		end
	end

	test "not unowned constraint" do
		Constraint.all.each do |constraint|
			assert User.all.include?(constraint.user)
		end
	end

end
