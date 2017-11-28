class CreateMeetingParticipations < ActiveRecord::Migration[5.1]
  def change
    create_table :meeting_participations do |t|
      t.boolean :is_admin
      t.boolean :is_consistent
      t.integer :response_status

      t.timestamps
    end
  end
end
