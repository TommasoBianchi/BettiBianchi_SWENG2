class AddDefaultLocationForeignKeysOnTravels < ActiveRecord::Migration[5.1]
  def change
    add_column :travels, :starting_location_dl_id, :integer
    add_foreign_key :travels, :default_locations, column: :starting_location_dl_id

    add_column :travels, :ending_location_dl_id, :integer
    add_foreign_key :travels, :default_locations, column: :ending_location_dl_id
  end
end
