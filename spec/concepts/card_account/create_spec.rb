require 'rails_helper'

RSpec.describe CardAccount::Create do
  let(:account) { create(:account) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product) }
  let(:op) { described_class }

  let(:params) { { product_id: product.id } }

  example 'creating a card - no person specified' do
    result = op.(
      params.merge(card: { product_id: product.id, opened_on: Date.today }),
      'account' => account,
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.person).to eq person # default
    expect(card.product).to eq product
    expect(card.closed_on).to be nil
    expect(card.opened_on).to eq Date.today
  end

  example 'creating a card - specifying a person-id' do
    companion = create(:companion, account: account)
    result = op.(
      params.merge(
        person_id: companion.id,
        card: {
          opened_on: Date.today,
          closed: false,
          product_id: product.id,
        },
      ),
      'account' => account,
    )
    expect(result.success?).to be true

    expect(result['model'].person).to eq companion
  end

  example 'creating a closed card' do
    result = op.(
      params.merge(
        card: {
          closed: true,
          closed_on: Date.today,
          opened_on: Date.yesterday,
        },
      ),
      'account' => account,
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.person).to eq person
    expect(card.product).to eq product
    expect(card.opened_on).to eq Date.yesterday
    expect(card.closed_on).to eq Date.today
  end

  it 'posts to a Zapier webhook' do
    expect(ZapierWebhooks::CardAccount::Created).to receive(:enqueue).with(kind_of(Card))
    op.(
      params.merge(card: { product_id: product.id, opened_on: Date.today }),
      'account' => account,
    )
  end

  example 'invalid save - opened in future' do
    result = op.(
      params.merge(card: { opened_on: Date.tomorrow, product_id: product.id }),
      'account' => account,
    )
    expect(result.success?).to be false
  end

  example 'invalid save - closed before opened' do
    result = op.(
      params.merge(
        card: {
          closed: true,
          closed_on: Date.today - 10,
          opened_on: Date.today,
        },
      ),
      'account' => account,
    )
    expect(result.success?).to be false
  end

  example 'failure - person belongs to a different account' do
    other_account = create(:account)
    expect do
      op.(
        params.merge(
          person_id: other_account.owner.id,
          card: {
            opened_on: Date.today,
            closed: false,
            product_id: product.id,
          },
        ),
        'account' => account,
      )
    end.to raise_error(ActiveRecord::RecordNotFound)

    expect(Card.count).to eq 0
  end
end
