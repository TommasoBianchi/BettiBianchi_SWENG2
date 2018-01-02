class Contact < ApplicationRecord
	belongs_to :user, foreign_key: :from_user, :class_name => 'User'
	belongs_to :to_user, foreign_key: :to_user, :class_name => 'User'

	#validate :no_double_contact
	#validate :no_contact_of_yourself

	private
	def no_double_contact
		if Contact.where(from_user: user).ids.include?(to_user)
			errors.add(:user, 'has already this contact')
		else
			puts(Contact.where(from_user: user).ids)
		end
	end

	def no_contact_of_yourself
		if from_user == to_user
			errors.add(:user, 'can not be the same of to_user')
			errors.add(:to_user, 'can not be the same of user')
		end
	end
end
