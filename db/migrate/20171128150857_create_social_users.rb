class CreateSocialUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :social_users do |t|
      t.string :link

      t.timestamps
    end
  end
end
