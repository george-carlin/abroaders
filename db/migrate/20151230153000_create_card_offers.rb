class CreateCardOffers < ActiveRecord::Migration[5.0]
  def change
    create_table :card_offers do |t|
      t.references :card, index: true, null: false, foreign_key: { on_delete: :cascade }
      t.string  :identifier, index: { unique: true }, null: false
      t.integer :points_awarded, null: false
      t.integer :spend, null: false
      t.integer :cost, null: false, default: 0
      t.integer :days, null: false, default: 90
      t.integer :status, null: false, index: true, default: 0

      t.timestamps
    end
  end
end
