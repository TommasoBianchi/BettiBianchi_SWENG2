class CreateConstraints < ActiveRecord::Migration[5.1]
  def change
    create_table :constraints do |t|
      t.integer :travel_mean

      t.timestamps
    end
  end
end
