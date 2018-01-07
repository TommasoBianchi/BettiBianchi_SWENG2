class CreateMeetingParticipationConflicts < ActiveRecord::Migration[5.1]
  def change
    create_table :meeting_participation_conflicts do |t|
      t.integer :meeting_participation_1_id
      t.integer :meeting_participation_2_id

      t.foreign_key :meeting_participations, column: :meeting_participation_1_id
      t.foreign_key :meeting_participations, column: :meeting_participation_2_id

      t.timestamps
    end
  end
end
