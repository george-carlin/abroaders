require 'rails_helper'

describe AdminArea::Card::Operations::Create do
  let(:person)  { create(:account).owner }
  let(:product) { create(:card_product) }

  example 'creating a card' do
    result = AdminArea::Card::Operations::Create.(
      person_id: person.id,
      card: { product_id: product.id, opened_at: Date.today },
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.product).to eq product
    expect(card.closed_at).to be nil
    expect(card.opened_at).to eq Date.today
  end

  example 'creating a closed card' do
    result = AdminArea::Card::Operations::Create.(
      person_id: person.id,
      card: {
        closed: true,
        closed_at: Date.today,
        opened_at: Date.yesterday,
        product_id: product.id,
      },
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.product).to eq product
    expect(card.opened_at).to eq Date.yesterday
    expect(card.closed_at).to eq Date.today
  end

  example 'invalid save - opened in future' do
    result = AdminArea::Card::Operations::Create.(
      person_id: person.id,
      card: { product_id: product.id, opened_at: Date.tomorrow },
    )
    expect(result.success?).to be false
  end

  example 'invalid save - closed before opened' do
    result = AdminArea::Card::Operations::Create.(
      person_id: person.id,
      card: {
        closed: true,
        closed_at: Date.yesterday,
        opened_at: Date.today,
        product_id: product.id,
      },
    )
    expect(result.success?).to be false
  end
end
