class AddFieldsToCardOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :card_offers, :link, :string, null: false
    add_column :card_offers, :notes, :text
    add_column :card_offers, :condition, :integer, null: false, default: 0
  end
end
