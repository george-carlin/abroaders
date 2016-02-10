class CreateCardAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :card_accounts do |t|
      t.integer  :card_id
      t.integer  :user_id,                        null: false
      t.integer  :offer_id
      t.integer  :status,                         null: false
      t.datetime :recommended_at
      t.datetime :applied_at
      t.datetime :opened_at
      t.datetime :earned_at
      t.datetime :closed_at
      t.boolean  :reconsidered,   default: false, null: false
      t.string   :decline_reason

      t.foreign_key :cards,                          on_delete: :restrict
      t.foreign_key :users,                          on_delete: :cascade
      t.foreign_key :card_offers, column: :offer_id, on_delete: :cascade

      t.timestamps
    end

  end
end
