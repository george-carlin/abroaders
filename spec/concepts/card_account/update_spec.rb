require 'rails_helper'

RSpec.describe CardAccount::Update do
  let(:bank)    { create(:bank, name: "Chase") }
  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product) }

  let(:nov_2015) { Date.new(2015, 11) }
  let(:dec_2015) { Date.new(2015, 12) }
  let(:jan_2016) { Date.new(2016, 1) }

  let(:params) { { card: {} } }

  example 'updating opened_on date' do
    card = Card.create!(person: person, product: product, opened_on: dec_2015)
    params[:card] = { opened_on: jan_2016 }
    params[:id]   = card.id
    result = described_class.(params, 'account' => account)
    expect(result.success?).to be true

    card = result['model']
    expect(card.closed_on).to be_nil
    expect(card.opened_on).to eq jan_2016
  end

  example 'closing an open card' do
    card = Card.create!(person: person, product: product, opened_on: dec_2015)
    params[:card] = { closed: true, closed_on: jan_2016, opened_on: dec_2015 }
    params[:id]   = card.id
    result = described_class.(params, 'account' => account)
    expect(result.success?).to be true

    card = result['model']
    expect(card.closed_on).to eq jan_2016
    expect(card.opened_on).to eq dec_2015
  end

  example 'unclosing a closed card' do
    card = Card.create!(
      person: person, product: product, opened_on: dec_2015, closed_on: jan_2016,
    )
    params[:card] = { opened_on: dec_2015 }
    params[:id]   = card.id
    result = described_class.(params, 'account' => account)
    expect(result.success?).to be true

    card = result['model']
    expect(card.closed_on).to be nil
    expect(card.opened_on).to eq dec_2015
  end

  example 'invalid save' do
    card = Card.create!(person: person, product: product, opened_on: dec_2015)
    # closed before opened:
    params[:card] = { opened_on: dec_2015, closed_on: nov_2015, closed: true }
    params[:id]   = card.id
    result = described_class.(params, 'account' => account)
    expect(result.success?).to be false
  end
end
