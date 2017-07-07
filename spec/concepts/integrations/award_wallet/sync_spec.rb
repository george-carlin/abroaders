require 'rails_helper'

RSpec.describe Integrations::AwardWallet::Sync do
  include AwardWalletMacros

  let(:op) { described_class }
  let(:account) { create_account(:onboarded) }

  example 'no AW user' do
    expect do
      op.({}, 'current_account' => account)
    end.to raise_error RuntimeError
  end

  context 'connected to AW' do
    let!(:user) { setup_award_wallet_user_from_sample_data(account) }

    example 'not already syncing' do
      expect do
        result = op.({}, 'current_account' => account)
        expect(result.success?).to be true
      end.to change { enqueued_jobs.size }.by(1)

      job = enqueued_jobs.last
      expect(job[:job]).to eq Integrations::AwardWallet::User::Refresh::Job
      expect(job[:args][0]['id']).to eq user.id

      expect(account.award_wallet_user.reload.syncing).to be true
    end

    example 'already syncing' do
      user.update!(syncing: true)

      expect do
        result = op.({}, 'current_account' => account)
        expect(result.success?).to be true
      end.not_to change { enqueued_jobs.size }

      expect(account.award_wallet_user.reload.syncing).to be true
    end
  end
end
