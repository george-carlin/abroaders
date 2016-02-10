class CreateCurrencies < ActiveRecord::Migration[5.0]
  def change
    create_table :currencies do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :award_wallet_id, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
