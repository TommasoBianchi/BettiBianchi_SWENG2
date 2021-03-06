# This class manages the model(relations, validations and base methods) of the IncompleteUser object
class IncompleteUser < ApplicationRecord
	validates :email, presence: true, uniqueness: true
	validates :password, presence: true

	validate :unique_email

	has_secure_password

	# Returns the hash digest of the given string.
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
							 BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	private

	# This method checks if the email is unique
	def unique_email
		return if email.blank?
		if Email.where(email: email).count > 0
			errors.add(:email, 'has already been taken')
		end
	end
end
