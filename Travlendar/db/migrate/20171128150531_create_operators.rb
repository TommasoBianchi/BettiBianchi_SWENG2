class CreateOperators < ActiveRecord::Migration[5.1]
  def change
    create_table :operators do |t|
      t.string :description
      t.integer :operator

      t.timestamps
    end
  end
end
