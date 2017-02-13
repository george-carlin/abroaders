require 'rails_helper'

RSpec.describe Account::Operation::Type::Onboard do
  let(:op) { described_class }
  let(:account) { create(:account, onboarding_state: :account_type) }

  example 'solo' do
    result = op.(
      { account: { type: 'solo' } },
      'account' => account,
    )
    expect(result.success?).to be true
    account.reload
    # doesn't add a companion:
    expect(account.companion).to be nil
    # updates the onboarding_state:
    expect(account.onboarding_state).to eq 'eligibility'
  end

  example 'couples' do
    result = op.(
      { account: { companion_first_name: ' George ', type: 'couples' } },
      'account' => account,
    )
    expect(result.success?).to be true
    account.reload
    # creates companion; strips whitespace from first name:
    companion = account.companion
    expect(companion).to be_persisted
    expect(companion.first_name).to eq 'George'
    # updates the onboarding_state:
    expect(account.onboarding_state).to eq 'eligibility'
  end
end
