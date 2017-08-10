class AddCardsCountToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :cards_count, :integer, null: false, default: 0
    add_column :card_products, :recommended_cards_count, :integer, null: false, default: 0

    reversible do |d|
      d.up { Offer.pluck(:id).each { |id| Offer.reset_counters(id, :cards) } }
    end
  end
end
