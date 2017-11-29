class User < ApplicationRecord
	has_many :group_users
	has_many :groups, through: :group_users
	has_many :social_users
	has_many :socials, through: :social_users
	has_many :emails
	has_one :email, foreign_key: :primary_email
	has_many :breaks
	has_many :statuses

	has_and_belongs_to_many :contacts, class_name: "User", 
                                     join_table: "contacts",
                                     foreign_key: "from_user",
                                     association_foreign_key: "to_user"


	#has_many :contacts, foreign_key: :from_user
	#has_many :users, through: :contacts #, foreign_key: :from_user
	#has_many :users, through: :contacts, foreign_key: :to_user
end
