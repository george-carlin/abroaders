class ChangeOfferStatusToBoolean < ActiveRecord::Migration[5.0]
  def change
    remove_index :card_offers, column: :status
    remove_column :card_offers, :status, :integer, default: 0, null: false
    add_column :card_offers, :live, :boolean, default: true, null: false
    add_index :card_offers, :live
  end
end
