class Social < ApplicationRecord
	has_many :social_users
	has_many :users, through: :social_users

	validates :name, :icon_path, presence: true

	#validate :icon_existence

	private
	def icon_existence
		if icon_path.blank?
			return
		end
		if Rails.application.assets.find_asset(icon_path).nil?
			errors.add(:icon_path, 'must point to an existing valid file')
		end
	end
end
