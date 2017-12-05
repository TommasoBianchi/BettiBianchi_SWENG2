class CreateStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :statuses do |t|
      t.integer :type
      t.datetime :from
      t.datetime :to

      t.timestamps
    end
  end
end
