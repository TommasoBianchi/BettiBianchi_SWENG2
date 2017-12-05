class PrimaryEmailUniqueness < ActiveRecord::Migration[5.1]
  def change
  	add_index :users, :primary_email_id, unique: true
  end
end
