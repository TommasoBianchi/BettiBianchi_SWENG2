class AddBreakForeignKeyToComputedBreaks < ActiveRecord::Migration[5.1]
  def change
  	add_column :computed_breaks, :break_id, :integer
    add_foreign_key :computed_breaks, :breaks
  end
end
