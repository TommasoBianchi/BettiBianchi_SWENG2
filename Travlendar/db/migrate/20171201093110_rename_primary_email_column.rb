class RenamePrimaryEmailColumn < ActiveRecord::Migration[5.1]
  def change
  	rename_column :users, :primary_email, :primary_email_id
  end
end
