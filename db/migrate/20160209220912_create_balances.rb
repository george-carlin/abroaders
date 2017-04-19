class CreateBalances < ActiveRecord::Migration[5.0]
  def change
    create_table :balances do |t|
      t.references :person, foreign_key: { on_delete: :cascade },
                                          null: false, index: true
      t.references :currency, foreign_key: { on_delete: :cascade },
                                          null: false, index: true
      t.integer :value, null: false

      t.index [:person_id, :currency_id], unique: true

      t.timestamps
    end
  end
end
