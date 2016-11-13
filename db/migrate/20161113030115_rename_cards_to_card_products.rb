class RenameCardsToCardProducts < ActiveRecord::Migration[5.0]
  def change
    rename_table :cards, :card_products

    rename_column :offers, :card_id, :product_id
    rename_column :card_accounts, :card_id, :product_id
  end
end
