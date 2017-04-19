class CreateCardAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :card_accounts do |t|
      t.integer  :card_id
      t.integer  :user_id, null: false
      t.integer  :offer_id
      t.datetime :recommended_at, index: true
      t.date     :applied_on
      t.date     :opened_on
      t.date     :closed_on
      t.string   :decline_reason
      t.datetime :clicked_at
      t.datetime :declined_at
      t.datetime :denied_at
      t.datetime :nudged_at
      t.datetime :called_at
      t.datetime :redenied_at
      t.datetime :seen_at, index: true
      t.datetime :expired_at
      t.datetime :pulled_at, index: true

      t.timestamps

      t.foreign_key :cards, on_delete: :restrict
      t.foreign_key :users, on_delete: :cascade
      t.foreign_key :offers, on_delete: :cascade
    end
  end
end
