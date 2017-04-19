class CreateCurrencies < ActiveRecord::Migration[5.0]
  def change
    create_table :currencies do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :award_wallet_id, null: false, index: { unique: true }
      t.timestamps
      t.boolean :shown_on_survey, null: false, default: true
      t.string :type, null: false, index: true
      t.string :alliance_name, null: false
    end
  end
end
