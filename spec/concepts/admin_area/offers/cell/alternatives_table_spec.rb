require 'cells_helper'

RSpec.describe AdminArea::Offers::Cell::AlternativesTable do
  describe '::Section' do
    let(:cell_class) { described_class::Section }

    let(:offer) { create_offer(attrs) }
    let(:card_product) { create(:card_product) }

    let(:attrs) do
      {
        card_product: card_product,
        condition: 'no_bonus',
        cost: 0,
        partner: 'card_benefit',
      }
    end

    before do # offers that aren't matches
      create_offer(attrs.except(:card_product))
      create_offer(attrs.merge(cost: 1))
      create_offer(card_product: card_product, condition: 'on_minimum_spend')
    end

    example '' do
      other_0 = create_offer(attrs.merge(value: 10))
      other_1 = create_offer(attrs.merge(partner: 'credit_cards'))

      rendered = cell(cell_class, offer).()
      expect(rendered).not_to have_selector "#offer_#{offer.id}"
      expect(rendered).to have_selector "#offer_#{other_0.id}"
      expect(rendered).to have_selector "#offer_#{other_1.id}"
    end

    example 'offer has no alternatives' do
      raise if AdminArea::Offers::AlternativesFor.(offer).any? # sanity check
      expect(raw_cell(cell_class, offer)).to \
        eq "<h4>Alternatives</h4>No alternatives found"
    end
  end
end
