require 'test_helper'

class SubjectTest < ActiveSupport::TestCase

	test "at least one operator and value" do
		Subject.all.each do |subject|
			assert Operator.where(subject: subject).count > 0
			assert Value.where(subject: subject).count > 0
		end
	end

	test "no subject with the same name" do
		Subject.all.each do |subject|
			assert Subject.where(name: subject.name).count == 1
		end
	end

end
