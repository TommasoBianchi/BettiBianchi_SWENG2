class CreateTravels < ActiveRecord::Migration[5.1]
  def change
    create_table :travels do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :travel_mean      
      t.numeric :distance

      t.timestamps
    end
  end
end
