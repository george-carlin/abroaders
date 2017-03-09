require 'rails_helper'

RSpec.describe Integrations::AwardWallet::User::Operation::Refresh do
  include AwardWalletMacros
  include SampleDataMacros

  let(:op) { described_class }

  let(:account) { create(:account, :onboarded) }

  let(:json) { sample_json('award_wallet_user') }
  before { stub_award_wallet_api(sample_json('award_wallet_user')) }

  let(:user) do
    Integrations::AwardWallet::Operation::Callback.(
      { userId: 12345 }, 'account' => account,
    )['model']
  end

  example 'initial load' do
    result = op.(user: user)
    expect(result.success?).to be true

    user = result['model']
    # see the specs for the Update op for the full test of user attrs being set
    expect(user.loaded).to be true
    expect(user.full_name).to eq 'John Smith'

    owners = user.award_wallet_owners
    expect(owners.length).to eq 2

    expect(owners.map(&:name)).to match_array ['John Smith', 'Fred Bloggs']

    john = owners.detect { |o| o.name == 'John Smith' }
    fred = owners.detect { |o| o.name == 'Fred Bloggs' }

    expect(john.award_wallet_accounts.length).to eq 2
    expect(fred.award_wallet_accounts.length).to eq 1

    expect(john.award_wallet_accounts.map(&:display_name)).to eq(
      ['British Airways (Executive Club)', 'Amex (Membership Rewards)'],
    )

    expect(fred.award_wallet_accounts[0].display_name).to eq(
      'American Airlines (AAdvantage)',
    )
  end

  example 'user no longer found on AwardWallet'

  example 'we have accounts and owners not present in API data' do
    result = op.(user: user)
    user   = result['model'].reload
    owner  = user.award_wallet_owners.first
    owner.update!(name: 'Deleteme')
    acc = user.award_wallet_owners.last.award_wallet_accounts.first
    acc.update!(aw_id: 987654321)

    result = op.(user: user)
    expect(result.success?).to be true
    user = result['model']
    expect(user.award_wallet_owners.count).to eq 2
    expect(user.award_wallet_accounts.count).to eq 3

    expect(AwardWalletOwner.find_by_id(owner.id)).to be nil
    expect(AwardWalletAccount.find_by_id(acc.id)).to be nil
  end
end
