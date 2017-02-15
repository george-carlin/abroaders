require 'rails_helper'

# 100% mutation coverage as of 14/2/17
RSpec.describe Balance::Operation::Update do
  let(:currency) { create(:currency) }
  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }
  let(:balance) do
    Balance::Operation::Create.(
      { balance: { value: 1234, currency_id: currency.id } },
      'account' => account,
      'person'  => person,
    )['model']
  end

  let(:op) { described_class }

  example 'updating value' do
    result = op.(
      {
        balance: { value: 4321 },
        id: balance.id,
      },
      'account' => account,
    )
    expect(result.success?).to be true

    balance.reload
    expect(balance.value).to eq 4321
    expect(balance).to eq result['model']
  end

  example 'invalid update' do
    result = op.(
      {
        balance: { value: -1 },
        id: balance.id,
      },
      'account' => account,
    )
    expect(result.success?).to be false
    expect(balance.reload.value).to eq 1234
  end

  example 'trying to update someone else\'s balance' do
    expect do
      op.(
        {
          balance: { value: -1 },
          id: balance.id,
        },
        'account' => create(:account),
      )
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
