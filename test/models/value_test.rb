require 'test_helper'

class ValueTest < ActiveSupport::TestCase

	test "no value without subject" do
		Value.all.each do |value|
			assert Subject.all.include?(value.subject)
		end
	end

	test "no values with the same subject and value" do
		Value.all.each do |value|
			puts(value.subject_id)
			puts(value.value)
			puts(Value.where(subject: value.subject, value: value.value).count)
			assert Value.where(subject: value.subject, value: value.value).count == 1
		end
	end

end
