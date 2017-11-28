class CreateBreaks < ActiveRecord::Migration[5.1]
  def change
    create_table :breaks do |t|
      t.time :default_time
      t.integer :duration
      t.time :start_time_slot
      t.time :end_time_slot
      t.string :name
      t.time :computed_time
      t.integer :day_of_the_week

      t.timestamps
    end
  end
end
