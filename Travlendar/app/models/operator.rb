class Operator < ApplicationRecord
  # This should be a constant
  #Problem that the system desn't find a methd caled equality on the class Operator, why?
  #Operators = [
  #	method(:inequality),
  #  method(:equality),
  #	method(:lesser_than),
  #	method(:greater_than)
  #]

  enum status: [
    :inequality,
    :equality,
    :lesser_than,
    :greater_than
  ]

  belongs_to :subject
  has_many :constraints

  validates :description, :operator, presence: true

  #validate :operator_correctness

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
