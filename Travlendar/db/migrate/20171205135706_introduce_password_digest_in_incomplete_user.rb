class IntroducePasswordDigestInIncompleteUser < ActiveRecord::Migration[5.1]
  def change
    rename_column :incomplete_users, :password, :password_digest
  end
end
