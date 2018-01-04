class Operator < ApplicationRecord

	belongs_to :subject
	has_many :constraints

	validates :description, :operator, presence: true

	validate :operator_correctness

	# This method invoke the action that the operator should perform
	def invoke(lval, rval)
		return Operators[operator].call lval, rval
	end

	private

	# This method checks if the operator is correct
	def operator_correctness
		if operator.blank?
			return
		end
		if operator < 0 or operator > Operators.length - 1
			errors.add(:operator, "must be between 0 and #{Operators.length - 1}")
		end
	end

	# Real operator
	def self.equality(a, b)
		return a == b
	end

	# Real operator
	def self.inequality(a, b)
		return a != b
	end

	# Real operator
	def self.lesser_than(a, b)
		return a < b
	end

	# Real operator
	def self.greater_than(a, b)
		return a > b
	end

	# This should be a constant
	Operators = [
			Operator.method(:equality),
			Operator.method(:inequality),
			Operator.method(:lesser_than),
			Operator.method(:greater_than)
	]

end
