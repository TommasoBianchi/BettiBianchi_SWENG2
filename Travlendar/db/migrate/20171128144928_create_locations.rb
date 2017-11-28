class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.numeric :longitude
      t.numeric :latitude
      t.string :description

      t.timestamps
    end
  end
end
