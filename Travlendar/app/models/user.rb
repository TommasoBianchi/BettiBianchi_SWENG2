# This class manages the model(relations, validations and base methods) of the User object
class User < ApplicationRecord
	has_many :group_users
	has_many :groups, through: :group_users
	has_many :social_users
	has_many :socials, through: :social_users
	has_many :emails
	has_many :breaks
	has_many :computed_breaks
	has_many :statuses

	has_and_belongs_to_many :contacts, class_name: 'User',
													join_table: 'contacts',
													foreign_key: 'from_user',
													association_foreign_key: 'to_user'

	has_many :default_locations
	has_many :meeting_participations
	has_many :constraints

	# This method returns the primary email of the user
	def primary_email
		Email.find(primary_email_id)
	end

	# Returns the hash digest of the given string.
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
							 BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	has_secure_password :validations => {:on => :create}
	validates :password, presence: true, :on => :create
	#validates :password_confirmation, presence: true, :on => :create
	validates :name, :surname, :nickname, :preference_list, presence: true
	validates :nickname, :primary_email_id, uniqueness: true

	validate :primary_email_in_emails
	validate :phone_number_consistency
	validate :at_least_one_travel_mean

	# This method returns the last default location before a given date
	def get_last_default_location_before(current_day)
		list_default_location = []
		default_locations.each do |dl|
			if dl.day_of_the_week < current_day.wday || ((dl.day_of_the_week == current_day.wday) && (dl.starting_hour <= (current_day.hour * 60 + current_day.min)))
				list_default_location.push dl
			end
		end
		list_default_location = list_default_location.sort_by {|dl1| [(dl1.day_of_the_week * 60 * 24 + dl1.starting_hour)]}

		if list_default_location.blank?
			get_last_default_location_before(DateTime.parse('December 9th 2017 11:59:59 PM')) # to take the last default location of the week, infinite loop if user doesn't have any def location
		else
			list_default_location.last
		end
	end

	# This method returns the first default location after a given date
	def get_first_location_after(current_day)
		list_default_location = []
		default_locations.each do |dl|
			if dl.day_of_the_week > current_day.wday || (dl.day_of_the_week == current_day.wday && dl.starting_hour >= (current_day.hour * 60 + current_day.min))
				list_default_location.push dl
			end
		end
		list_default_location = list_default_location.sort_by {|dl1| [(dl1.day_of_the_week * 60 * 24 + dl1.starting_hour)]}

		if list_default_location.blank?
			get_first_location_after(DateTime.parse('December 10th 2017 00:00:00 AM')) # to take the first default location of the week, infinite loop if user doesn't have any def location
		else
			list_default_location.first
		end
	end

	private

	# This method checks if the user always has at least one travel mean available
	def at_least_one_travel_mean
		unless preference_list.length > 0
			errors.add(:preference_list, 'can not be empty')
		end
	end

	# This method checks if the phone number inserted is valid
	def phone_number_consistency
		if phone_number
			is_number = /^[0-9]+$/
			unless is_number.match?(phone_number)
				errors.add(:phone_number, 'is not valid!')
			end
		end
	end

	# This method checks if the primary email is present
	def primary_email_in_emails
		nil if primary_email_id.blank?
	end
end
