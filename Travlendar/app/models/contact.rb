class Contact < ApplicationRecord
	belongs_to :user, foreign_key: :from_user, :class_name => 'User'
	belongs_to :to_user, foreign_key: :to_user, :class_name => 'User'
end