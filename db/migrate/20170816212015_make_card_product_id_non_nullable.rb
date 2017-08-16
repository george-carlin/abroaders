class MakeCardProductIdNonNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :cards, :card_product_id, false
  end
end
