require 'rails_helper'

# 100% mutation coverage as of 8/3/17
RSpec.describe Integrations::AwardWallet::User::Update do
  include AwardWalletMacros
  include SampleDataMacros
  let(:op) { described_class }

  let(:account) { create_account }

  stub_award_wallet_api_key!

  before { stub_award_wallet_api(sample_json('award_wallet_user')) }

  let(:data) { Integrations::AwardWallet::APIClient.connected_user(12345) }

  let(:user) { get_award_wallet_user_from_callback(account) }

  example '.call' do
    result = op.(user: user, data: data)
    expect(result.success?).to be true

    user.reload

    expect(user).to eq result['model']

    expect(user.aw_id).to eq 12345
    expect(user.full_name).to eq 'John Smith'
    expect(user.status).to eq 'Free'
    expect(user.user_name).to eq 'JSmith'
    expect(user.email).to eq 'JSmith@email.com'
    expect(user.forwarding_email).to eq 'JSmith@AwardWallet.com'
    expect(user.access_level).to eq 'Regular'
    expect(user.accounts_access_level).to eq 'Full control'
    expect(user.agent_id).to eq 112232
    expect(user.loaded).to be true
  end
end
