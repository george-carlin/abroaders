class OfferProductIdRename < ActiveRecord::Migration[5.0]
  def change
    rename_column :offers, :product_id, :card_product_id
  end
end
