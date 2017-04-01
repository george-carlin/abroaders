class CreateAwardWalletUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :award_wallet_users do |t|
      t.references :account, foreign_key: { on_delete: :cascade }, null: false, index: true
      t.integer :aw_id, null: false, index: true
      t.boolean :loaded, null: false, default: false
      t.integer :agent_id
      t.string :full_name
      t.string :user_name
      t.string :status
      t.string :email
      t.string :forwarding_email
      t.string :access_level
      t.string :accounts_access_level

      t.timestamps null: false
    end
  end
end
