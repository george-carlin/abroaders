class RenameUsersToAccounts < ActiveRecord::Migration[5.0]
  def change
    rename_table :users, :accounts
    rename_column :surveys, :user_id, :account_id
    rename_column :travel_plans, :user_id, :account_id
    rename_column :card_accounts, :user_id, :passenger_id
    rename_column :balances, :user_id, :passenger_id
    remove_foreign_key "card_accounts", "accounts"
    add_foreign_key "card_accounts", "passengers", column: "passenger_id",
                                                   on_delete: :cascade
    remove_foreign_key "balances", "accounts"
    add_foreign_key "balances", "passengers", column: "passenger_id",
                                              on_delete: :cascade
  end
end
