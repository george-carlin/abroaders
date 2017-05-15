require 'rails_helper'

RSpec.describe RecommendationRequest::Create do
  let(:op) { described_class }
  let(:account) { create_account(:eligible, :onboarded) }
  let(:owner) { account.owner }

  context 'solo account' do
    example 'success' do
      result = op.({ person_type: 'owner' }, 'account' => account)
      expect(result.success?).to be true
      expect(owner.reload.unresolved_recommendation_request?).to be true
    end

    example 'failure - person ineligible' do
      owner.update!(eligible: false)
      result = op.({ person_type: 'owner' }, 'account' => account)
      expect(result.success?).to be false
      expect(owner.unresolved_recommendation_request?).to be false
      expect(result['error']).to eq "#{owner.first_name} can't request a recommendation"
    end

    example 'failure - person has unresolved request' do
      # create an existing request:
      run!(op, { person_type: 'owner' }, 'account' => account)
      # and try again:
      owner.reload
      expect do
        result = op.({ person_type: 'owner' }, 'account' => account)
        expect(result.success?).to be false
        expect(result['error']).to eq "#{owner.first_name} can't request a recommendation"
      end.not_to change { RecommendationRequest.count }
    end

    example 'failure - person has unresolved recs' do
      create_rec(person: owner)
      owner.reload
      result = op.({ person_type: 'owner' }, 'account' => account)
      expect(result.success?).to be false
      expect(owner.unresolved_recommendation_request?).to be false
      expect(result['error']).to eq "#{owner.first_name} can't request a recommendation"
    end

    example 'noisy failure - requesting for companion' do
      expect do
        op.({ person_type: 'companion' }, 'account' => account)
      end.to raise_error(RuntimeError)
    end
  end

  context 'couples account' do
    let!(:companion) { create_companion(account: account, eligible: true) }

    # account.companion returns nil unless you reload:
    before { account.reload }

    context 'creating request for owner' do
      example 'success' do
        result = op.({ person_type: 'owner' }, 'account' => account)
        expect(result.success?).to be true
        expect(owner.reload.unresolved_recommendation_request?).to be true
        expect(companion.reload.unresolved_recommendation_request?).to be false
      end

      example 'failure - owner already has unresolved request' do
        run!(op, { person_type: 'owner' }, 'account' => account)
        raise unless owner.reload.unresolved_recommendation_request? # sanity check
        expect do
          result = op.({ person_type: 'owner' }, 'account' => account)
          expect(result.success?).to be false
        end.not_to change { RecommendationRequest.count }
      end

      example 'failure - owner has unresolved recs' do
        create_rec(person: owner)
        expect do
          result = op.({ person_type: 'owner' }, 'account' => account)
          expect(result.success?).to be false
        end.not_to change { RecommendationRequest.count }
      end
    end

    context 'creating request for companion' do
      example 'success' do
        result = op.({ person_type: 'companion' }, 'account' => account)
        expect(result.success?).to be true
        expect(companion.unresolved_recommendation_request?).to be true
        expect(owner.unresolved_recommendation_request?).to be false
      end

      example 'failure - companion already has unresolved request' do
        run!(op, { person_type: 'companion' }, 'account' => account)
        raise unless companion.unresolved_recommendation_request? # sanity check
        account.reload
        expect do
          result = op.({ person_type: 'companion' }, 'account' => account)
          expect(result.success?).to be false
        end.not_to change { RecommendationRequest.count }
      end

      example 'failure - companion has unresolved recs' do
        create_rec(person: companion)
        expect do
          result = op.({ person_type: 'companion' }, 'account' => account)
          expect(result.success?).to be false
        end.not_to change { RecommendationRequest.count }
      end
    end

    context 'for both people' do
      example 'success' do
        result = op.({ person_type: 'both' }, 'account' => account)
        expect(result.success?).to be true
        expect(owner.unresolved_recommendation_request?).to be true
        expect(companion.unresolved_recommendation_request?).to be true
      end

      example 'failure - one or both people ineligible' do
        expect do
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
        end.not_to change { RecommendationRequest.count }
      end
    end
  end
end
