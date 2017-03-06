class CreateAwardWalletAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :award_wallet_accounts do |t|
      t.references :award_wallet_owner, foreign_key: { on_delete: :cascade }, null: false
      t.integer :aw_id, null: false, index: true
      t.string :display_name, null: false
      t.string :kind, null: false
      t.string :login, null: false
      t.integer :balance_raw, null: false
      t.integer :error_code, null: false
      t.string :error_message
      t.string :last_detected_change
      t.datetime :expiration_date
      t.datetime :last_retrieve_date
      t.datetime :last_change_date

      t.timestamps
    end
  end
end
