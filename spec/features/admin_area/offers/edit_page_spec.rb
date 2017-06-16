require 'rails_helper'

RSpec.describe 'admin - offer edit pages' do
  include_context 'logged in as admin'

  let(:offer)   { create_offer }
  let(:product) { offer.card_product }

  let(:route) { edit_admin_offer_path(offer) }

  it 'displays information about the product' do
    visit route
    expect(page).to have_content product.name
  end

  it 'displays information about the offer' do
    visit route
    condition = find('#offer_condition option[selected]')
    expect(condition.value).to eq offer.condition

    partner = find('#offer_partner option[selected]')
    expect(partner.value).to eq offer.partner

    points_awarded = find('#offer_points_awarded')
    expect(points_awarded.value.to_i).to eq offer.points_awarded

    offer_spend = find('#offer_spend')
    expect(offer_spend.value.to_i).to eq offer.spend

    offer_cost = find('#offer_cost')
    expect(offer_cost.value.to_i).to eq offer.cost

    offer_days = find('#offer_days')
    expect(offer_days.value.to_i).to eq offer.days

    offer_link = find('#offer_link')
    expect(offer_link.value).to eq offer.link
  end

  example 'when offer is live' do
    visit route
    expect(page).to have_no_button 'Unkill Offer'
  end

  example 'when offer is dead' do
    kill_offer(offer)
    visit route
    expect(page).to have_button 'Unkill Offer'
    click_button 'Unkill Offer'
    expect(offer.reload.killed_at).to be nil
    expect(current_path).to eq admin_offer_path(offer)
    visit route
    expect(page).to have_no_button 'Unkill Offer'
  end
end
