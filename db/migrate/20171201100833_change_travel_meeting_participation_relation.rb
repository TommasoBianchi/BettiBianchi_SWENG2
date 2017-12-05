class ChangeTravelMeetingParticipationRelation < ActiveRecord::Migration[5.1]
  def change
  	remove_column :travels, :meeting_participation_id

    add_column :meeting_participations, :arriving_travel_id, :integer
    add_foreign_key :meeting_participations, :travels, column: :arriving_travel_id

    add_column :meeting_participations, :leaving_travel_id, :integer
    add_foreign_key :meeting_participations, :travels, column: :leaving_travel_id
  end
end
