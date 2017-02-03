require 'rails_helper'

RSpec.describe Card::Operations::Create do
  let(:account) { create(:account) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product) }
  let(:op) { described_class }

  example 'creating a card' do
    result = op.(
      { card: { product_id: product.id, opened_at: Date.today } },
      'account' => account,
      'person' => person,
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.person).to eq person
    expect(card.product).to eq product
    expect(card.closed_at).to be nil
    expect(card.opened_at).to eq Date.today
  end

  example 'creating a closed card' do
    result = op.(
      {
        card: {
          closed: true,
          closed_at: Date.today,
          opened_at: Date.yesterday,
          product_id: product.id,
        },
      },
      'account' => account,
      'person' => person,
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.person).to eq person
    expect(card.product).to eq product
    expect(card.opened_at).to eq Date.yesterday
    expect(card.closed_at).to eq Date.today
  end

  example 'invalid save - opened in future' do
    result = op.(
      { card: { opened_at: Date.tomorrow, product_id: product.id } },
      'account' => account,
      'person' => person,
    )
    expect(result.success?).to be false
  end

  example 'invalid save - closed before opened' do
    result = op.(
      {
        card: {
          closed: true,
          closed_at: Date.yesterday,
          opened_at: Date.today,
          product_id: product.id,
        },
      },
      'account' => account,
      'person' => person,
    )
    expect(result.success?).to be false
  end
end
