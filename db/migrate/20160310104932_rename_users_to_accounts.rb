class RenameUsersToAccounts < ActiveRecord::Migration[5.0]
  def change
    rename_table :users, :accounts
    rename_column :surveys, :user_id, :account_id
    rename_column :travel_plans, :user_id, :account_id
  end
end
