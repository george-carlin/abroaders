class RemoveIdentifierFromOffers < ActiveRecord::Migration[5.0]
  def change
    remove_index  :card_offers, column: :identifier, unique: true
    remove_column :card_offers, :identifier, :string, null: false
  end
end
