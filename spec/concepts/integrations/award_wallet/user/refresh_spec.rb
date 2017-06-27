require 'rails_helper'

RSpec.describe Integrations::AwardWallet::User::Refresh do
  include AwardWalletMacros
  include SampleDataMacros

  let(:op) { described_class }

  let(:account) { create_account(:onboarded) }
  let(:owner)   { account.owner }

  let(:json) { sample_json('award_wallet_user') }
  before { stub_award_wallet_api(sample_json('award_wallet_user')) }

  let(:user) { get_award_wallet_user_from_callback(account) }

  example 'initial load' do
    result = op.(user: user)
    expect(result.success?).to be true

    user = result['model']
    # see the specs for the Update op for the full test of user attrs being set
    expect(user.loaded).to be true
    expect(user.syncing).to be false
    expect(user.full_name).to eq 'John Smith'

    owners = user.award_wallet_owners
    expect(owners.length).to eq 2

    expect(owners.map(&:name)).to match_array ['John Smith', 'Fred Bloggs']

    john = owners.detect { |o| o.name == 'John Smith' }
    fred = owners.detect { |o| o.name == 'Fred Bloggs' }

    # owner.person is owner by default:
    expect(john.person).to eq owner
    expect(fred.person).to eq owner

    expect(john.award_wallet_accounts.length).to eq 3
    expect(fred.award_wallet_accounts.length).to eq 1

    expect(john.award_wallet_accounts.map(&:display_name)).to eq(
      [
        'British Airways (Executive Club)',
        'Amex (Membership Rewards)',
        'American Airlines (AAdvantage)',
      ],
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
    expect(user.award_wallet_accounts.count).to eq 4

    expect(AwardWalletOwner.find_by_id(owner.id)).to be nil
    expect(AwardWalletAccount.find_by_id(acc.id)).to be nil
  end

  example 'user is syncing' do
    aw_user = run!(op, user: user)['model'].reload
    aw_user.update!(syncing: true)

    result = op.(user: user)
    expect(result.success?).to be true
    expect(aw_user.reload.syncing).to be false
  end

  example 'when an existing owner is not assigned to a person' do
    owners = op.(user: user)['model'].award_wallet_owners
    john = owners.detect { |o| o.name == 'John Smith' }
    fred = owners.detect { |o| o.name == 'Fred Bloggs' }

    run!(
      Integrations::AwardWallet::Owner::UpdatePerson,
      { id: john.id, person_id: nil },
      'account' => account,
    )

    # refresh again:
    op.(user: user)

    john.reload
    fred.reload
    expect(john.person).to be nil
    expect(fred.person).to eq owner
  end

  example '::Job' do
    expect(op).to receive(:call).with(user: user)
    described_class::Job.perform_now('id' => user.id)
  end
end
