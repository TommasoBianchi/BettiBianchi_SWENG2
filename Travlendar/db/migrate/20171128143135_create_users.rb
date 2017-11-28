class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :surname
      t.string :nickname
      t.string :password
      t.string :company
      t.string :website
      t.text :brief
      t.string :phone_number
      t.string :preference_list

      t.timestamps
    end
  end
end
