class AddDetailsToTravelSteps < ActiveRecord::Migration[5.1]
  def change
  	add_column :travel_steps, :description, :string, null: false
  	add_column :travel_steps, :from, :string 
  	add_column :travel_steps, :to, :string
  end
end
