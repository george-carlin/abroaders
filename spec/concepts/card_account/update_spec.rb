require 'rails_helper'

RSpec.describe CardAccount::Update do
  let(:op) { described_class }

  let(:account) { create_account(:onboarded) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product) }

  let(:nov_2015) { Date.new(2015, 11) }
  let(:dec_2015) { Date.new(2015, 12) }
  let(:jan_2016) { Date.new(2016, 1) }

  let(:params) { { card: {} } }

  example 'updating opened_on date' do
    card_account = create_card_account(person: person, card_product: product, opened_on: dec_2015)
    params[:card] = { opened_on: jan_2016 }
    params[:id] = card_account.id
    result = op.(params, 'account' => account)
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.closed_on).to be_nil
    expect(card_account.opened_on).to eq jan_2016
  end

  example 'closing an open card account' do
    card_account = create_card_account(person: person, card_product: product, opened_on: dec_2015)
    params[:card] = { closed: true, closed_on: jan_2016, opened_on: dec_2015 }
    params[:id] = card_account.id
    result = op.(params, 'account' => account)
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.closed_on).to eq jan_2016
    expect(card_account.opened_on).to eq dec_2015
  end

  example 'unclosing a closed card account' do
    card_account = create_card_account(
      person: person, card_product: product, opened_on: dec_2015, closed_on: jan_2016,
    )
    params[:card] = { opened_on: dec_2015 }
    params[:id] = card_account.id
    result = op.(params, 'account' => account)
    expect(result.success?).to be true

    card_account = result['model']
    expect(card_account.closed_on).to be nil
    expect(card_account.opened_on).to eq dec_2015
  end

  example 'invalid save' do
    card_account = create_card_account(person: person, card_product: product, opened_on: dec_2015)
    # closed before opened:
    params[:card] = { opened_on: dec_2015, closed_on: nov_2015, closed: true }
    params[:id] = card_account.id
    result = op.(params, 'account' => account)
    expect(result.success?).to be false
  end

  example "trying to update someone else's account" do
    card_account = create_card_account(person: person, card_product: product, opened_on: dec_2015)
    params[:card] = { opened_on: jan_2016 }
    params[:id] = card_account.id

    other_account = create_account(:onboarded)
    expect do
      op.(params, 'account' => other_account)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
