require 'rails_helper'

RSpec.describe RecommendationRequest::Confirm do
  let(:op) { described_class }
  let(:account) { create(:account, :eligible, :onboarded) }
  let(:owner) { account.owner }

  let(:create_req_op) { RecommendationRequest::Create }

  example 'success - solo account with unconfirmed request' do
    run!(create_req_op, { person_type: 'owner' }, 'account' => account)
    result = op.({}, 'account' => account)
    expect(result.success?).to be true
    owner.reload
    expect(owner.unconfirmed_recommendation_request).to be nil
    expect(owner.confirmed_recommendation_requests.count).to eq 1
  end

  example 'failure - solo account without unconfirmed request' do
    result = op.({}, 'account' => account)
    expect(result.success?).to be false
    expect(owner.confirmed_recommendation_requests.count).to eq 0
  end

  context 'couples account' do
    let!(:companion) { create(:companion, account: account, eligible: true) }

    # account.companion returns nil unless you reload:
    before { account.reload }

    example 'success - one person has unconfirmed request' do
      run!(create_req_op, { person_type: 'owner' }, 'account' => account)
      result = op.({}, 'account' => account)
      expect(result.success?).to be true
      owner.reload
      expect(owner.unconfirmed_recommendation_request).to be nil
      expect(owner.confirmed_recommendation_requests.count).to eq 1
      expect(companion.confirmed_recommendation_requests.count).to eq 0
    end

    example 'success - both people have unconfirmed requests' do
      run!(create_req_op, { person_type: 'both' }, 'account' => account)
      result = op.({}, 'account' => account)
      expect(result.success?).to be true
      expect(account.unconfirmed_recommendation_requests.count).to eq 0
      expect(owner.confirmed_recommendation_requests.count).to eq 1
      expect(companion.confirmed_recommendation_requests.count).to eq 1
    end

    example 'success - one unconfirmed request, one confirmed one' do
      # create and confirm the first req:
      run!(create_req_op, { person_type: 'owner' }, 'account' => account)
      run!(op, {}, 'account' => account)
      # now create a second one:
      run!(create_req_op, { person_type: 'companion' }, 'account' => account)

      account.reload # tests fail if you don't reload here
      expect do
        result = op.({}, 'account' => account)
        expect(result.success?).to be true
      end.to change { companion.confirmed_recommendation_requests.count }.by(1)
      expect(account.unconfirmed_recommendation_requests.count).to eq 0
    end

    example 'failure - no unconfirmed requests' do
      # create and confirm some pre-existing reqs:
      run!(create_req_op, { person_type: 'both' }, 'account' => account)
      run!(op, {}, 'account' => account)
      account.reload # tests fail if you don't reload here
      raise unless account.unconfirmed_recommendation_requests.none? # sanity check
      # now try 'confirming' again:
      expect do
        result = op.({}, 'account' => account)
        expect(result.success?).to be false
      end.not_to change { RecommendationRequest.count }
    end
  end
end
