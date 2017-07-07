require 'rails_helper'

RSpec.describe Integrations::AwardWallet::Account::Update do
  include AwardWalletMacros
  before { setup_award_wallet_user_from_sample_data(account) }

  let(:account) { create_account(:onboarded) }
  let(:awa) { account.award_wallet_accounts.last }
  let(:original_balance) { awa.balance }

  let(:op) { described_class }

  example 'updating balance' do
    result = op.(
      {
        award_wallet_account: { balance: 4321 },
        id: awa.id,
      },
      'current_account' => account,
    )
    expect(result.success?).to be true

    awa.reload
    expect(awa.balance).to eq 4321
    expect(awa).to eq result['model']
  end

  example 'invalid update' do
    result = op.(
      {
        award_wallet_account: { balance: -1 },
        id: awa.id,
      },
      'current_account' => account,
    )
    expect(result.success?).to be false
    expect(awa.reload.balance).to eq original_balance
  end

  example 'trying to update someone else\'s AW account' do
    expect do
      op.(
        {
          award_wallet_account: { balance: -1 },
          id: awa.id,
        },
        'current_account' => create_account,
      )
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
