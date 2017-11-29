class AddForeignKeysToUser < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :primary_email, :integer
  	add_foreign_key :users, :emails, column: :primary_email

  	add_column :social_users, :user_id, :integer
  	add_foreign_key :social_users, :users
  	add_column :social_users, :social_id, :integer
  	add_foreign_key :social_users, :socials

  	add_column :emails, :user_id, :integer
  	add_foreign_key :emails, :users

  	add_column :breaks, :user_id, :integer
  	add_foreign_key :breaks, :users

  	add_column :statuses, :user_id, :integer
  	add_foreign_key :statuses, :users

  	add_column :group_users, :user_id, :integer
  	add_foreign_key :group_users, :users
  	add_column :group_users, :group_id, :integer
  	add_foreign_key :group_users, :groups

  	add_column :contacts, :from_user, :integer
  	add_foreign_key :contacts, :users, column: :from_user
  	add_column :contacts, :to_user, :integer
  	add_foreign_key :contacts, :users, column: :to_user

    add_column :default_locations, :user_id, :integer
    add_foreign_key :default_locations, :users
    add_column :default_locations, :location_id, :integer
    add_foreign_key :default_locations, :locations

    add_column :constraints, :user_id, :integer
    add_foreign_key :constraints, :users

    add_column :meeting_participations, :user_id, :integer
    add_foreign_key :meeting_participations, :users
    add_column :meeting_participations, :meeting_id, :integer
    add_foreign_key :meeting_participations, :meetings

    add_column :travles, :meeting_participation_id, :integer
    add_foreign_key :travles, :meeting_participations

    add_column :travel_steps           , :user_id, :integer
    add_foreign_key :meeting_participations, :users
  end
end
