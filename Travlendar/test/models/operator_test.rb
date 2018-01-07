require 'test_helper'

class OperatorTest < ActiveSupport::TestCase

	test "no operator without subject" do
		Operator.all.each do |operator|
			assert Subject.all.include?(operator.subject)
		end
	end

	test "no operators with the same subject and operator" do
		Operator.all.each do |operator|
			assert Operator.where(subject: operator.subject, operator: operator.operator).count == 1
		end
	end

end
