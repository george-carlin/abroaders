require 'rails_helper'

RSpec.describe Integrations::AwardWallet::Operation::Callback do
  include AwardWalletMacros

  let(:op) { described_class }

  let(:account) { create(:account, :onboarded) }

  example 'account already has a loaded AWU' do
    setup_award_wallet_user_from_sample_data(account)

    # userId param is irrelevant:
    [nil, 1, 2].each do |aw_id|
      result = op.({ userId: aw_id }, 'account' => account)
      expect(result['error']).to eq 'already loaded'
      expect(enqueued_jobs).to be_empty
    end
  end

  example 'account already has an unloaded AWU' do
    # operation succeeds, but don't queue a new BG job:
    user = get_award_wallet_user_from_callback(account)

    # userId param is irrelevant:
    [12345, 2, nil].each do |aw_id|
      result = op.({ userId: aw_id }, 'account' => account)
      expect(result.success?).to be true
      expect(result['error']).to be nil
      expect(result['model']).to eq user
      expect(result['model'].aw_id).to eq 1
      expect(result['model'].loaded).to be false
      expect(enqueued_jobs).to be_empty
    end
  end

  example 'no existing AWU, no userId in params' do
    result = op.({}, 'account' => account)
    expect(result.success?).to be false
    expect(result['error']).to eq 'not found'
    expect(enqueued_jobs).to be_empty
  end

  example 'no existing AWU; normal flow' do
    # operation succeeds, and queues a new BG job
    raise unless account.award_wallet_user.nil? # sanity check
    result = nil
    expect do
      result = op.({ userId: 1 }, 'account' => account)
    end.to change { enqueued_jobs.size }.by(1)
    expect(result.success?).to be true
    awu = result['model']
    expect(awu).to eq account.reload.award_wallet_user
    expect(awu.aw_id).to eq 1
    expect(awu.loaded).to be false
    job = enqueued_jobs.last
    expect(job[:job]).to eq Integrations::AwardWallet::User::Operation::Refresh::Job
    expect(job[:args][0]['id']).to eq awu.id
  end
end
