require 'rails_helper'

RSpec.describe Card::Operations::Create do
  let(:account) { create(:account) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product) }
  let(:op) { described_class }

  let(:params) { { product_id: product.id } }

  example 'creating a card - no person specified' do
    result = op.(
      params.merge(card: { product_id: product.id, opened_at: Date.today }),
      'account' => account,
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.person).to eq person # default
    expect(card.product).to eq product
    expect(card.closed_at).to be nil
    expect(card.opened_at).to eq Date.today
  end

  example 'creating a card - specifying a person-id' do
    companion = create(:companion, account: account)
    result = op.(
      params.merge(
        card: {
          opened_at: Date.today,
          closed: false,
          person_id: companion.id,
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
          closed_at: Date.today,
          opened_at: Date.yesterday,
        },
      ),
      'account' => account,
    )
    expect(result.success?).to be true

    card = result['model']
    expect(card.person).to eq person
    expect(card.product).to eq product
    expect(card.opened_at).to eq Date.yesterday
    expect(card.closed_at).to eq Date.today
  end

  it 'posts to a Zapier webhook' do
    expect(ZapierWebhooks::Card::Created).to receive(:enqueue).with(kind_of(Card))
    op.(
      params.merge(card: { product_id: product.id, opened_at: Date.today }),
      'account' => account,
    )
  end

  example 'invalid save - opened in future' do
    result = op.(
      params.merge(card: { opened_at: Date.tomorrow, product_id: product.id }),
      'account' => account,
    )
    expect(result.success?).to be false
  end

  example 'invalid save - closed before opened' do
    result = op.(
      params.merge(
        card: {
          closed: true,
          closed_at: Date.today - 10,
          opened_at: Date.today,
        },
      ),
      'account' => account,
    )
    expect(result.success?).to be false
  end
end
