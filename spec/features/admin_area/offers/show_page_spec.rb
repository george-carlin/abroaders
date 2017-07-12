require 'rails_helper'

RSpec.describe 'admin - show offer page' do
  include_context 'logged in as admin'

  let(:attrs) do
    {
      card_product: product,
      condition: 'on_minimum_spend',
      cost: 0,
      days: 90,
      points_awarded: 10_000,
      spend: 3000,
      notes: 'my notes',
    }
  end

  let(:offer) { create_offer(attrs) }
  let(:product) { create(:card_product) }
  let(:card_product) { product }

  let(:route) { admin_offer_path(offer) }

  it 'displays information about the offer and product' do
    visit route
    expect(page).to have_content product.name
    expect(page).to have_content 'CardBenefit'
    expect(page).to have_content offer.notes
  end

  describe 'alternative offers table' do
    example 'not present' do
      # not a match:
      other_offer = create_offer(card_product: card_product)
      visit route
      expect(page).to have_no_selector "#offer_#{other_offer.id}"
      expect(page).to have_no_selector '.offer_alternatives_table'
      expect(page).to have_content 'No alternatives found'
    end

    example 'present' do
      alt_1 = create_offer(attrs)
      alt_2 = create_offer(attrs)
      dead_alt = kill_offer(create_offer(attrs))
      other_offer = create_offer(card_product: card_product)
      visit route
      expect(page).to have_selector '.offer_alternatives_table'
      expect(page).to have_selector "#offer_#{alt_1.id}"
      expect(page).to have_selector "#offer_#{alt_2.id}"
      expect(page).to have_no_selector "#offer_#{dead_alt.id}"
      expect(page).to have_no_selector "#offer_#{other_offer.id}"
      expect(page).to have_no_content 'No alternatives found'
    end
  end

  example 'active recs table'
end
