class CreateSocials < ActiveRecord::Migration[5.1]
  def change
    create_table :socials do |t|
      t.string :name
      t.string :icon_path

      t.timestamps
    end
  end
end
