class CreateCardOffers < ActiveRecord::Migration[5.0]
  def change
    create_table :offers do |t|
      t.references :card, index: true, null: false, foreign_key: { on_delete: :cascade }
      t.integer :points_awarded, null: false
      t.integer :spend
      t.integer :cost, null: false
      t.integer :days
      t.timestamps
      t.string :link, null: false
      t.text :notes
      t.datetime :last_reviewed_at
      t.datetime :killed_at, index: true
      t.string :partner, null: false, default: 'none'
      t.string :condition, null: false
    end
  end
end
