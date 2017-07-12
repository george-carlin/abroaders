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

  describe 'active recs table' do
    example 'no active recs' do
      for_wrong_offer = create_rec(offer: create_offer)
      visit route
      expect(page).to have_no_selector "#card_recommendation_#{for_wrong_offer.id}"
      expect(page).to have_no_selector '#offer_active_recs_table'
      expect(page).to have_content 'No active card recommendations'
    end

    example 'present' do
      rec_1 = create_rec(offer: offer)
      rec_2 = create_rec(offer: offer)
      other_recs = [ # recs that shouldn't appear in the table:
        create_rec(offer: create_offer), # wrong offer
        decline_rec(create_rec(:declined)),
        create_rec(:applied, offer: offer),
        create_rec(:applied, :opened, offer: offer),
      ]
      visit route
      expect(page).to have_selector '#offer_active_recs_table'
      expect(page).to have_selector "#card_recommendation_#{rec_1.id}"
      expect(page).to have_selector "#card_recommendation_#{rec_2.id}"
      other_recs.each do |rec|
        expect(page).to have_no_selector "#card_recommendation_#{rec.id}"
      end
    end

    example 'deleting a rec' do
      rec = create_rec(offer: offer)
      id = rec.id
      visit route

      selector = "#card_recommendation_#{id}"
      within selector do
        click_link 'Del'
      end

      expect(Card.exists?(id: id)).to be false

      # Make sure we're still on the same page:
      expect(current_path).to eq admin_offer_path(offer)
      expect(page).to have_no_selector selector
    end
  end
end
