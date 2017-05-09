class RemoveBanks < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :card_products, :banks

    drop_table :banks
  end
end
