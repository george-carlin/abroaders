require 'rails_helper'

RSpec.describe CardAccount::Create do
  let(:account) { create_account }
  let(:person) { account.owner }
  let(:card_product) { create(:card_product) }
  let(:op) { described_class }

  example 'creating a card account - no person specified' do
    result = op.(
      {
        card_product_id: card_product.id,
        card: { opened_on: Date.today },
      },
      'account' => account,
    )
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.person).to eq person # default
    expect(card_account.card_product).to eq card_product
    expect(card_account.closed_on).to be nil
    expect(card_account.opened_on).to eq Date.today
  end

  example 'creating a card account - specifying a person-id' do
    companion = create_companion(account: account)
    result = op.(
      {
        person_id: companion.id,
        card_product_id: card_product.id,
        card: { opened_on: Date.today, closed: false },
      },
      'account' => account,
    )
    expect(result.success?).to be true

    expect(result['model'].person).to eq companion
  end

  example 'creating a closed card account' do
    result = op.(
      {
        card_product_id: card_product.id,
        card: {
          closed: true,
          closed_on: Date.today,
          opened_on: Date.yesterday,
        },
      },
      'account' => account,
    )
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.person).to eq person
    expect(card_account.card_product).to eq card_product
    expect(card_account.opened_on).to eq Date.yesterday
    expect(card_account.closed_on).to eq Date.today
  end

  example 'invalid save - opened in future' do
    result = op.(
      {
        card_product_id: card_product.id,
        card: { opened_on: Date.tomorrow },
      },
      'account' => account,
    )
    expect(result.success?).to be false
  end

  example 'invalid save - closed before opened' do
    result = op.(
      {
        card_product_id: card_product.id,
        card: {
          closed: true,
          closed_on: Date.today - 10,
          opened_on: Date.today,
        },
      },
      'account' => account,
    )
    expect(result.success?).to be false
  end

  example 'failure - person belongs to a different account' do
    other_account = create_account
    expect do
      op.(
        {
          person_id: other_account.owner.id,
          card_product_id: card_product.id,
          card: { opened_on: Date.today, closed: false },
        },
        'account' => account,
      )
    end.to raise_error(ActiveRecord::RecordNotFound)

    expect(Card.count).to eq 0
  end
end
