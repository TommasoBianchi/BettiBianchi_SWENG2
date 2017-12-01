class IncompleteUser < ApplicationRecord
	validates :email, presence: true, uniqueness: true
	validates :password, presence: true

	validate :unique_email

	private 
	def unique_email
		if email.blank?
			return
		end		
		if Email.where(email: email).count > 0
			errors.add(:email, 'has already been taken')
		end
	end
end
