class AddCurrencyIdToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :currency_id, :string, null: false
  end
end
