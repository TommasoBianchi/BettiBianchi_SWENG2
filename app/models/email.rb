# This class manages the model(relations, validations and base methods) of the Email object
class Email < ApplicationRecord
	belongs_to :user, optional: true

	validates :email, presence: true, uniqueness: true
	validate :is_email

	before_save do
		self.email = email.downcase
	end

	private

	# This method checks if the email is valid
	def is_email
		reg_ex_pattern = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
		unless reg_ex_pattern.match?(email)
			errors.add(:email, "must be a valid email")
		end
	end
end
