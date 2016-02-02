class AddCurrencyIdToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :currency_id, :integer, null: false
    add_index :cards, :currency_id
  end
end
