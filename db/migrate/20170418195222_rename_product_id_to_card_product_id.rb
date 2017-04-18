class RenameProductIdToCardProductId < ActiveRecord::Migration[5.0]
  def change
    rename_column :cards, :product_id, :card_product_id
  end
end
