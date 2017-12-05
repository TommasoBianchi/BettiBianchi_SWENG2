class CreateIncompleteUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :incomplete_users do |t|
      t.string :password, null: false
      t.string :email, null: false

      t.timestamps
    end

    add_index :incomplete_users, :email, unique: true
  end
end
