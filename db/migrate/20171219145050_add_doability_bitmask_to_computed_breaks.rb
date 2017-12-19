class AddDoabilityBitmaskToComputedBreaks < ActiveRecord::Migration[5.1]
  def change
  	add_column :computed_breaks, :doability_bitmask, "BIT VARYING(1440)"
  end
end
