class AddUnknownOffers < ActiveRecord::Migration[5.0]
  def change
    change_column_null :offers, :cost, true
    change_column_null :offers, :link, true

    Offer.reset_column_information

    # TODO test this much more thoroughly before running in production
    # TODO how can I add a DB constraint so that there's only one 'unknown'
    # offer per card product?
    reversible do |d|
      d.up do
        CardProduct.find_each do |product|
          Offer.find_or_create_by!(card_product: product, condition: 'unknown')
        end

        Card.where(offer_id: nil).each do |card|
          # card.card_product won't work here:
          product = CardProduct.find(card.attributes['card_product_id'])
          offer = Offer.find_by!(condition: 'unknown', card_product_id: product.id)
          card.update!(offer: offer)
        end

        remove_foreign_key :cards, :card_products
      end
      d.down do
        Offer.unknown.find_each do |offer|
          offer.cards.update_all(offer_id: nil)
          offer.destroy
        end

        Card.find_each do |card|
          card.update!(card_product: card.offer.card_product) if card.offer
        end

        change_column_null :cards, :card_product_id, false
        add_foreign_key :cards, :card_products, column: :card_product_id
      end
    end

    change_column_null :cards, :offer_id, false

    remove_column :cards, :card_product_id, :integer, index: true
  end
end
