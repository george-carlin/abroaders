class RenameCardsOffersToOffers < ActiveRecord::Migration[5.0]
  def change
    rename_table :card_offers, :offers
  end
end
