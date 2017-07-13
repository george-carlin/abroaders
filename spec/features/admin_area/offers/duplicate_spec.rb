require 'rails_helper'

RSpec.describe 'admin area - duplicating an offer' do
  # note that the 'duplicate' page is just OffersController#new with an extra
  # param in the URL.

  include_context 'logged in as admin'

  let(:card_product) { offer.card_product }
  let(:offer) do
    create_offer(
      condition: 'on_minimum_spend',
      partner: 'credit_cards',
      points_awarded: 40_000,
      cost: 100,
      days: 60,
      spend: 1000,
      link: 'http://whatever.example.com',
      value: 150,
      notes: 'these are notes',
    )
  end

  let(:route) do
    new_admin_card_product_offer_path(card_product, duplicate_id: offer.id)
  end

  example '' do
    visit route

    # form fields are prefilled, except link:
    # expect(page).to have_select :offer_condition, selected: 'on_minimum_spend'
    # expect(page).to have_select :offer_partner, selected: 'credit_cards'
    expect(page).to have_field :offer_points_awarded, with: 40_000
    expect(page).to have_field :offer_cost, with: 100
    expect(page).to have_field :offer_days, with: 60
    expect(page).to have_field :offer_spend, with: 1000
    expect(page).to have_field :offer_value, with: '150.0'
    expect(page).to have_field :offer_notes, with: 'these are notes'
    expect(page).to have_field :offer_link

    expect(find('#offer_link').value).to be_blank

    # picking a link and saving:
    fill_in :offer_link, with: 'http://example.com/whatever_mate'
    expect do
      click_button 'Submit'
    end.to change { card_product.offers.count }.by(1)

    new_offer = card_product.offers.last

    expect(new_offer.condition).to eq 'on_minimum_spend'
    expect(new_offer.partner).to eq 'credit_cards'
    expect(new_offer.points_awarded).to eq 40_000
    expect(new_offer.cost).to eq 100
    expect(new_offer.days).to eq 60
    expect(new_offer.spend).to eq 1000
    expect(new_offer.value).to eq 150
    expect(new_offer.notes).to eq 'these are notes'
    expect(new_offer.link).to eq 'http://example.com/whatever_mate'

    # these timestamps shouldn't be copied
    expect(new_offer.last_reviewed_at).to be_nil
    expect(new_offer.killed_at).to be_nil
  end

  example 'dead offers can be duplicated' do
    kill_offer(offer)
    visit route

    # picking a link and saving:
    fill_in :offer_link, with: 'http://example.com/whatever_mate'
    expect do
      click_button 'Submit'
    end.to change { card_product.offers.count }.by(1)

    new_offer = card_product.offers.last
    # these timestamps shouldn't be copied
    expect(new_offer.last_reviewed_at).to be_nil
    expect(new_offer.killed_at).to be_nil
  end
end
