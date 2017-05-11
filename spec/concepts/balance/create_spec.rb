require 'rails_helper'

RSpec.describe Balance::Create do
  let(:op) { described_class }
  let(:currency) { create_currency }
  let(:account)  { create(:account, :onboarded) }
  let(:person)   { account.owner }

  example 'valid save' do
    result = op.(
      {
        balance: {
          currency_id: currency.id,
          value: 1,
        },
        person_id: person.id,
      },
      'account' => account,
    )
    expect(result.success?).to be true

    balance = result['model']
    expect(balance).to be_persisted
    expect(balance.value).to eq 1
    expect(balance.currency).to eq currency
  end

  example 'invalid save' do
    result = op.(
      {
        balance: {
          value:       -1,
          currency_id: currency.id,
        },
        person_id: person.id,
      },
      'account' => account,
    )
    expect(result.success?).to be false
  end
end
