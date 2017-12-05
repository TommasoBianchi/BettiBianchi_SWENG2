class CreateComputedBreaks < ActiveRecord::Migration[5.1]
  def change
    create_table :computed_breaks do |t|
      t.datetime :computed_time
      t.datetime :start_time_slot
      t.datetime :end_time_slot
      t.integer :duration
      t.string :name
      t.boolean :is_doable
      t.integer :user_id

      t.timestamps
    end

    add_foreign_key :computed_breaks, :users

    change_table :breaks do |t|
      t.remove :computed_time
      t.remove :default_time
      t.remove :start_time_slot
      t.remove :end_time_slot
      t.integer :default_time
      t.integer :start_time_slot
      t.integer :end_time_slot
    end
  end
end
