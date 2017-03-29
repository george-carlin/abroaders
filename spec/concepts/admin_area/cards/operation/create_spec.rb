require 'rails_helper'

RSpec.describe AdminArea::Cards::Operation::Create do
  let(:person)  { create(:account).owner }
  let(:product) { create(:card_product) }
  let(:op)      { described_class }

  example 'creating a card' do
    result = op.(
      person_id: person.id,
      card: { product_id: product.id, opened_on: Date.today },
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.product).to eq product
    expect(card.closed_on).to be nil
    expect(card.opened_on).to eq Date.today
  end

  example 'creating a closed card' do
    result = op.(
      person_id: person.id,
      card: {
        closed: true,
        closed_on: Date.today,
        opened_on: Date.today - 2,
        product_id: product.id,
      },
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.product).to eq product
    expect(card.opened_on).to eq(Date.today - 2)
    expect(card.closed_on).to eq Date.today
  end

  example 'invalid save - opened in future' do
    result = op.(
      person_id: person.id,
      card: { product_id: product.id, opened_on: (Date.today + 1) },
    )
    expect(result.success?).to be false
  end

  example 'invalid save - closed before opened' do
    result = op.(
      person_id: person.id,
      card: {
        closed: true,
        closed_on: (Date.today - 2),
        opened_on: Date.today,
        product_id: product.id,
      },
    )
    expect(result.success?).to be false
  end
end
