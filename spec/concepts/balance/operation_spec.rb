require 'rails_helper'

describe Balance::Create do
  let(:currency) { create(:currency) }
  let(:account)  { create(:account, :onboarded) }
  let(:person)   { account.owner }

  example 'valid save' do
    res, op = described_class.run(
      balance: {
        value:       1,
        currency_id: currency.id,
      },
      current_account: account,
      person_id:       person.id,
    )
    expect(res).to be true

    balance = op.model
    expect(balance.value).to eq 1
    expect(balance.currency).to eq currency
  end

  example 'invalid save' do
    res, = described_class.run(
      balance: {
        value:       -1,
        currency_id: currency.id,
      },
      current_account: account,
      person_id: person.id,
    )
    expect(res).to be false
  end
end
