class ConvertBpToBoolean < ActiveRecord::Migration[5.0]
  def change
    add_column :card_products, :personal, :boolean

    CardProduct.where(bp: 0).update_all(personal: false)
    CardProduct.where(bp: 1).update_all(personal: true)
    change_column_null :card_products, :personal, false

    remove_column :card_products, :bp, :integer, null: false
  end
end
