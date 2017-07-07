require 'rails_helper'

# 100% mutation coverage as of 14/2/17
RSpec.describe Balance::Update do
  let(:account) { create_account(:onboarded) }
  let(:balance) { create_balance(value: 1234, person: account.owner) }

  let(:op) { described_class }

  example 'updating value' do
    result = op.(
      {
        balance: { value: 4321 },
        id: balance.id,
      },
      'current_account' => account,
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
      'current_account' => account,
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
        'current_account' => create_account,
      )
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
