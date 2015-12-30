class CreateCardAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :card_accounts do |t|
      t.integer :card_id, null: false
      t.integer :user_id, null: false
      t.integer  :status, null: false
      t.datetime :recommended
      t.datetime :applied
      t.datetime :opened
      t.datetime :earned
      t.datetime :closed

      t.timestamps
    end

    add_foreign_key :card_accounts, :cards
    add_foreign_key :card_accounts, :users
  end
end
