class AddFacebookTokenToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :fb_token, :string
    add_index :accounts, :fb_token
  end
end
