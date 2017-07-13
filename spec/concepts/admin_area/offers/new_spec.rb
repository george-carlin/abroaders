require 'rails_helper'

RSpec.describe AdminArea::Offers::New do
  let(:op) { described_class }

  let(:card_product) { create(:card_product) }

  example '' do
    result = op.(card_product_id: card_product.id)
    expect(result.success?).to be true
    form = result['contract.default']

    # Nothing set except defaults:
    expect(form.condition).to eq 'on_minimum_spend'
    expect(form.partner).to eq 'none'
    expect(form.points_awarded).to be_nil
    expect(form.spend).to eq 0
    expect(form.cost).to eq 0
    expect(form.days).to eq 90
    expect(form.link).to be_nil
    expect(form.value).to be_nil
    expect(form.notes).to be_nil
  end

  example 'with "duplicate" param' do
    offer = create_offer(
      card_product: card_product,
      condition: 'on_first_purchase',
      partner: 'award_wallet',
      points_awarded: 50_000,
      cost: 100,
      days: 60,
      link: 'http://whatever.example.com',
      value: 150,
      notes: 'these are notes',
    )

    result = op.(card_product_id: card_product.id, duplicate_id: offer.id)
    expect(result.success?).to be true
    form = result['contract.default']

    expect(form.condition).to eq 'on_first_purchase'
    expect(form.partner).to eq 'award_wallet'
    expect(form.points_awarded).to eq 50_000
    expect(form.spend).to eq 0 # form default
    expect(form.cost).to eq 100
    expect(form.days).to eq 60
    expect(form.value).to eq 150
    expect(form.notes).to eq 'these are notes'
    expect(form.link).to be_blank
  end
end
