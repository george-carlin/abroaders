require 'rails_helper'

RSpec.describe AdminArea::CardAccounts::Create do
  let(:person)  { create(:account).owner }
  let(:product) { create(:card_product) }
  let(:op)      { described_class }

  example 'success - creating an open card account' do
    result = op.(
      person_id: person.id,
      card_account: { product_id: product.id, opened_on: Date.today },
    )
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.product).to eq product
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
        product_id: product.id,
      },
    )
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.product).to eq product
    expect(card_account.opened_on).to eq(Date.today - 2)
    expect(card_account.closed_on).to eq Date.today
  end

  example 'failure - invalid save - opened in future' do
    result = op.(
      person_id: person.id,
      card_account: { product_id: product.id, opened_on: (Date.today + 1) },
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
        product_id: product.id,
      },
    )
    expect(result.success?).to be false
  end
end
