class AddForeignKeysToMeetingTravels < ActiveRecord::Migration[5.1]
  def change
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

        add_column :travel_steps, :travel_is, :integer
        add_foreign_key :travel_steps, :travels

        add_column :meetings, :location_id, :integer
        add_foreign_key :meetings, :locations
  end
end
