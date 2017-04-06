require 'rails_helper'

RSpec.describe RecommendationRequest::Create do
  let(:op) { described_class }
  let(:account) { create(:account, :eligible, :onboarded) }
  let(:owner) { account.owner }

  example 'success - solo account owner' do
    result = op.({ person_type: 'owner' }, 'account' => account)
    expect(result.success?).to be true
    expect(owner.unconfirmed_recommendation_request).to be_present
  end

  context 'couples account' do
    let!(:companion) { create(:companion, account: account, eligible: true) }

    # account.companion returns nil unless you reload:
    before { account.reload }

    example 'success - owner only' do
      result = op.({ person_type: 'owner' }, 'account' => account)
      expect(result.success?).to be true
      expect(owner.unconfirmed_recommendation_request).to be_present
      expect(companion.unconfirmed_recommendation_request).to be_nil
    end

    example 'success - companion only' do
      result = op.({ person_type: 'companion' }, 'account' => account)
      expect(result.success?).to be true
      expect(owner.unconfirmed_recommendation_request).to be_nil
      expect(companion.unconfirmed_recommendation_request).to be_present
    end

    example 'success - both people' do
      result = op.({ person_type: 'both' }, 'account' => account)
      expect(result.success?).to be true
      expect(owner.unconfirmed_recommendation_request).to be_present
      expect(companion.unconfirmed_recommendation_request).to be_present
    end

    example 'failure - one or both people ineligible' do
      owner.update!(eligible: false)
      result = op.({ person_type: 'both' }, 'account' => account)
      expect(result.success?).to be false
      expect(result['error']).to eq "#{owner.first_name} can't request a recommendation"

      companion.update!(eligible: false)
      account.reload # test fails if you don't reload
      result = op.({ person_type: 'both' }, 'account' => account)
      expect(result.success?).to be false
      msg = "#{owner.first_name} and #{companion.first_name} can't request a recommendation"
      expect(result['error']).to eq msg

      owner.update!(eligible: true)
      account.reload # test fails if you don't reload
      result = op.({ person_type: 'both' }, 'account' => account)
      expect(result.success?).to be false
      expect(result['error']).to eq "#{companion.first_name} can't request a recommendation"
    end
  end

  example 'failure - person ineligible' do
    owner.update!(eligible: false)
    result = op.({ person_type: 'owner' }, 'account' => account)
    expect(result.success?).to be false
    expect(owner.unconfirmed_recommendation_request).to be_nil
    expect(result['error']).to eq "#{owner.first_name} can't request a recommendation"
  end

  example 'failure - person has unresolved request' do
    # create an existing request:
    run!(op, { person_type: 'owner' }, 'account' => account)
    # and try again:
    expect do
      result = op.({ person_type: 'owner' }, 'account' => account)
      expect(result.success?).to be false
      expect(result['error']).to eq "#{owner.first_name} can't request a recommendation"
    end.not_to change { RecommendationRequest.count }
  end

  example 'failure - person has unresolved recs' do
    create_rec(person: owner)
    owner.reload
    # and try again:
    result = op.({ person_type: 'owner' }, 'account' => account)
    expect(result.success?).to be false
    expect(owner.unconfirmed_recommendation_request).to be_nil
    expect(result['error']).to eq "#{owner.first_name} can't request a recommendation"
  end

  example 'noisy failure - solo account, requesting for companion' do
    expect do
      op.({ person_type: 'companion' }, 'account' => account)
    end.to raise_error(RuntimeError)
  end
end
