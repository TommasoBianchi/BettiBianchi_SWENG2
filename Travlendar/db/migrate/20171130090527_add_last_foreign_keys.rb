class AddLastForeignKeys < ActiveRecord::Migration[5.1]
  def change
    add_column :operators, :subject_id, :integer
    add_foreign_key :operators, :subjects

    add_column :values, :subject_id, :integer
    add_foreign_key :values, :subjects

    add_column :constraints, :subject_id, :integer
    add_foreign_key :constraints, :subjects

    add_column :constraints, :operator_id, :integer
    add_foreign_key :constraints, :operators

    add_column :constraints, :value_id, :integer
    add_foreign_key :constraints, :values

    add_column :categories, :superclass_id, :integer
  end
end
