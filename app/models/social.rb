class Social < ApplicationRecord
	has_many :social_users
	has_many :users, through: :social_users

	Social_type = {
			1 => {name: 'facebook', icon_path: 'social_icons/facebook_icon.png', social_id: 1},
			2 => {name: 'linkedin', icon_path: 'social_icons/linkedin_icon.png', social_id: 2},
			3 => {name: 'instagram', icon_path: 'social_icons/instagram_icon.png', social_id: 3}
	}

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

# Facebook 1
# Linkedin 2
# Instagram 3