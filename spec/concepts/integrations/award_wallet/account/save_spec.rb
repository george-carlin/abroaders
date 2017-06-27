require 'rails_helper'

# 100% mutation coverage as of 8th Mar 2017
RSpec.describe Integrations::AwardWallet::Account::Save do
  include AwardWalletMacros
  include SampleDataMacros
  let(:op) { described_class }
  let(:account) { create_account(:couples, :onboarded) }

  stub_award_wallet_api_key!

  before { stub_award_wallet_api(sample_json('award_wallet_account')) }

  let(:data) { Integrations::AwardWallet::APIClient.account(7654321) }

  let(:user) { get_award_wallet_user_from_callback(account) }

  let(:owner_name) { data['owner'] }

  context "when User doesn't already have this account" do
    def it_has_correct_attributes(account)
      expect(account.aw_id).to eq 7654321
      expect(account.display_name).to eq 'British Airways (Executive Club)'
      expect(account.kind).to eq 'Airlines'
      expect(account.login).to eq 'johnsmith'
      expect(account.balance_raw).to eq 146780
      expect(account.error_code).to eq 2
      expect(account.error_message).to eq 'invalid credentials'
      expect(account.last_detected_change).to eq '+750'
      expect(account.expiration_date).to eq Time.utc(2018, 12, 10)
      expect(account.last_retrieve_date).to eq Time.utc(2016,  1, 15)
      expect(account.last_change_date).to eq Time.utc(2016, 1, 15, 0, 49, 33)
    end

    example 'and recognises the owner' do
      owner = user.award_wallet_owners.create!(
        name: owner_name,
        person: account.companion,
      )

      result = op.(user: user, account_data: data)
      expect(result.success?).to be true

      aw_account = result['model']
      expect(aw_account.award_wallet_user).to eq user

      aw_owner = aw_account.award_wallet_owner
      expect(aw_owner).to eq owner
      # doesn't change the person:
      expect(aw_owner.person).to eq account.companion

      it_has_correct_attributes(aw_account)
    end

    example 'recognises the owner, owner person is nil' do
      owner = user.award_wallet_owners.create!(name: owner_name, person: nil)

      aw_account = op.(user: user, account_data: data)['model']
      aw_owner   = aw_account.award_wallet_owner
      # doesn't change the person:
      expect(aw_owner).to eq owner
      expect(aw_owner.person).to be nil
    end

    example "and doesn't recognise the owner" do
      result = op.(user: user, account_data: data)
      expect(result.success?).to be true

      aw_account = result['model']
      expect(aw_account.award_wallet_user).to eq user

      aw_owner = aw_account.award_wallet_owner
      expect(aw_owner.name).to eq owner_name
      # AW account owner = Abroaders account owner by default.
      # Aargh, confusing terminology!
      expect(aw_owner.person).to eq account.owner

      it_has_correct_attributes(aw_account)
    end

    example 'and account currency is AA' do
      # American Airlines is a special case because AwardWallet can't tell us
      # the balance via the API (even though we can still see the balance in
      # the business interface in a browser) as part of their contract with AA.
      # So the balance will be the string "restricted".
      path = Rails.root.join('spec/support/sample_data/award_wallet_account_american_airlines.json')
      data = Abroaders::Util.underscore_keys(JSON.parse(File.read(path)), true)
      result = nil
      expect do
        result = op.(user: user, account_data: data)
        expect(result.success?).to be true
      end.to change { user.award_wallet_accounts.count }.by(1)

      account = result['model']
      expect(account.aw_id).to eq 3605103
      expect(account.display_name).to eq 'American Airlines (AAdvantage)'
      expect(account.kind).to eq 'Airlines'
      expect(account.login).to eq 'restricted'
      expect(account.balance_raw).to eq 0 # we'll need extra logic for displaying this correctly.
      expect(account.error_code).to eq 1
      expect(account.error_message).to be_nil
      expect(account.last_detected_change).to eq 'restricted'
      expect(account.expiration_date).to eq Time.utc(2018, 12, 21, 2, 13, 38)
      expect(account.last_retrieve_date).to eq Time.utc(2017,  6, 22)
      expect(account.last_change_date).to eq Time.utc(2017, 6, 22, 8, 11, 46)
    end
  end

  context "when User already has this account" do
    before do
      @owner = user.award_wallet_owners.create!(name: owner_name)
      result = op.(user: user, account_data: data)
      raise unless result.success? # sanity check
      @account = result['model']
    end

    let(:new_data) do
      { # keep the account ID the same but change (some of) the other data:
        account_id: 7654321,
        display_name: 'British Airways (Executive Club)',
        kind: 'Airlines',
        login: 'qwerty',
        balance_raw: 149999,
        owner: owner_name,
        error_code: 5,
        error_message: 'something',
        last_detected_change: '+1000',
        expiration_date: data['expiration_date'],
        last_retrieve_date: data['last_retrieve_date'],
        last_change_date: data['last_change_date'],
      }.stringify_keys
    end

    example 'but recognises the owner' do
      result = op.(user: user, account_data: new_data)

      expect(result.success?).to be true
      account = result['model']
      expect(account).to eq @account
      expect(account.owner).to eq @owner
      expect(account.login).to eq 'qwerty'
      expect(account.balance_raw).to eq 149999
      expect(account.error_code).to eq 5
      expect(account.error_message).to eq 'something'
      expect(account.last_detected_change).to eq '+1000'
    end

    example "and doesn't recognise the owner" do
      new_data['owner'] = 'Fred Bloggs'

      result = nil
      expect do
        result = op.(user: user, account_data: new_data)
      end.to change { AwardWalletOwner.count }.by(1)
      expect(result.success?).to be true

      new_owner = AwardWalletOwner.last
      expect(new_owner.name).to eq 'Fred Bloggs'

      account = result['model']
      # it should update the existing record, not create a new one:
      expect(account).to eq @account
      expect(account.owner).to eq new_owner
      expect(account.login).to eq 'qwerty'
      expect(account.balance_raw).to eq 149999
      expect(account.owner).to eq new_owner
      expect(account.error_code).to eq 5
      expect(account.error_message).to eq 'something'
      expect(account.last_detected_change).to eq '+1000'
    end
  end
end
