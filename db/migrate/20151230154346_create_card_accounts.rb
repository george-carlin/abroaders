class CreateCardAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :card_accounts do |t|
      t.integer  :card_id
      t.integer  :user_id, null: false
      t.integer  :status, null: false
      t.datetime :recommended_at
      t.datetime :applied_at
      t.datetime :opened_at
      t.datetime :earned_at
      t.datetime :closed_at
      t.boolean  :reconsidered, default: false, null: false

      t.timestamps
    end

    add_foreign_key :card_accounts, :cards, on_delete: :restrict
    add_foreign_key :card_accounts, :users, on_delete: :cascade
  end
end
