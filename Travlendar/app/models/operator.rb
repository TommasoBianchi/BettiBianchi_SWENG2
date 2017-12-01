class Operator < ApplicationRecord
  # This should be a constant
  Operators = [
  	method(:equality),
  	method(:inequality),
  	method(:lesser_than),
  	method(:greater_than)
  ]

  belongs_to :subject
  has_many :constraints

  validates :description, :operator, presence: true

  validates :operator_correctness

  private
  def operator_correctness
  	if operator.blank?
  		return
  	end
  	unless operator < 0 or operator > Operators.length - 1
  		errors.add(:operator, "must be between 0 and #{Operators.length - 1}")
    end
  end

  # Real operators
  def equality(a, b)
  	return a == b
  end

  def inequality(a, b)
  	return a != b 
  end

  def lesser_than(a, b)
  	return a < b 
  end

  def greater_than(a, b)
  	return a > b 
  end
end
