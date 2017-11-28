class CreateMeetings < ActiveRecord::Migration[5.1]
  def change
    create_table :meetings do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :title
      t.text :abstract

      t.timestamps
    end
  end
end
