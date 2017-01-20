require 'rails_helper'

describe Balance::Create do
  let(:currency) { create(:currency) }
  let(:account)  { create(:account, :onboarded) }
  let(:person)   { account.owner }

  example 'valid save' do
    result = Balance::Create.(
      {
        balance: {
          currency_id: currency.id,
          value: 1,
        },
      },
      'person' => person,
    )
    expect(result.success?).to be true

    balance = result['model']
    expect(balance).to be_persisted
    expect(balance.value).to eq 1
    expect(balance.currency).to eq currency
  end

  example 'invalid save' do
    result = described_class.(
      {
        balance: {
          value:       -1,
          currency_id: currency.id,
        },
      },
      'person' => person,
    )
    expect(result.success?).to be false
  end
end
