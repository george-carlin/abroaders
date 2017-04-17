require 'rails_helper'

RSpec.describe AdminArea::CardAccounts::Create do
  let(:op) { described_class }

  let(:person) { create(:account).owner }
  let(:card_product) { create(:card_product) }

  example 'success - creating an open card account' do
    result = op.(
      person_id: person.id,
      card_account: { product_id: card_product.id, opened_on: Date.today },
    )
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.product).to eq card_product
    expect(card_account.closed_on).to be nil
    expect(card_account.opened_on).to eq Date.today
  end

  example 'success - creating a closed card account' do
    result = op.(
      person_id: person.id,
      card_account: {
        closed: true,
        closed_on: Date.today,
        opened_on: Date.today - 2,
        product_id: card_product.id,
      },
    )
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.product).to eq card_product
    expect(card_account.opened_on).to eq(Date.today - 2)
    expect(card_account.closed_on).to eq Date.today
  end

  example 'failure - invalid save - opened in future' do
    result = op.(
      person_id: person.id,
      card_account: { product_id: card_product.id, opened_on: (Date.today + 1) },
    )
    expect(result.success?).to be false
  end

  example 'failure - invalid save - closed before opened' do
    result = op.(
      person_id: person.id,
      card_account: {
        closed: true,
        closed_on: (Date.today - 2),
        opened_on: Date.today,
        product_id: card_product.id,
      },
    )
    expect(result.success?).to be false
  end
end
