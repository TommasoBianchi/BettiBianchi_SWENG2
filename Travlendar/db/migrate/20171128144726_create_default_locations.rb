class CreateDefaultLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :default_locations do |t|
      t.time :starting_hour
      t.integer :day_of_the_week
      t.string :name

      t.timestamps
    end
  end
end
