class RenameSurveysToPassengers < ActiveRecord::Migration[5.0]
  def change
    rename_table :surveys, :passengers
    add_column :passengers, :main, :boolean, null: false, default: true
    # There are two types of passengers: 'main' and 'companion'. An account
    # will always have one main passenger, and optionally one companion
    # passenger.
    remove_index :passengers, :account_id
    add_index :passengers, [:account_id, :main], unique: true

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
