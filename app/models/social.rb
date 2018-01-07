# This class manages the model(relations, validations and base methods) of the Social object
class Social < ApplicationRecord
	has_many :social_users
	has_many :users, through: :social_users

	# This should be a constant
	Social_type = {
			1 => {name: 'Facebook', icon_path: 'social_icons/facebook_icon.png', social_id: 1},
			2 => {name: 'Linkedin', icon_path: 'social_icons/linkedin_icon.png', social_id: 2},
			3 => {name: 'Instagram', icon_path: 'social_icons/instagram_icon.png', social_id: 3}
	}

	validates :name, :icon_path, presence: true

	#validate :icon_existence

	private

	# This method checks if the icon path exists for a social
	def icon_existence
		if icon_path.blank?
			return
		end
		if Rails.application.assets.find_asset(icon_path).nil?
			errors.add(:icon_path, 'must point to an existing valid file')
		end
	end
end
