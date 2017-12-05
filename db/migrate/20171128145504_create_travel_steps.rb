class CreateTravelSteps < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_steps do |t|
      t.integer :travel_mean
      t.datetime :start_time
      t.datetime :end_time
      t.numeric :distance

      t.timestamps
    end
  end
end
