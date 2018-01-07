require 'test_helper'

class ComputedBreakTest < ActiveSupport::TestCase

  test "belongs to a real break" do
		ComputedBreak.all.each do |br|
			assert Break.exists?(br.break_id)
		end
	end

end
