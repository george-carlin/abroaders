require 'rails_helper'

RSpec.describe RecommendationRequest::Policy do
  include_context 'create_rec avoids extra records'

  let(:account) { create(:account, :eligible, :onboarded) }
  let(:person) { account.owner }

  describe '#create?' do
    shared_examples 'one person' do
      example 'with an unresolved rec request' do
        create_rec_request('owner', account)
        account.reload
        expect(result).to be false
      end

      example 'with a resolved rec request' do
        create_rec_request('owner', account)
        run!(AdminArea::CardRecommendations::Complete, person_id: person.id)
        expect(result).to be true
      end

      example 'with resolved recommendations' do
        create_card_recommendation(:applied, person: person)
        create_card_recommendation(:expired, person: person)
        # and a declined one:
        decline_rec(create_rec(person: person))

        expect(result).to be true
      end

      example 'with unresolved recommendations' do
        # same as the 'resolved' spec, plus one unresolved one
        create_card_recommendation(:applied, person: person)
        create_card_recommendation(:expired, person: person)
        # and a declined one:
        decline_rec(create_rec(person: person))

        create_card_recommendation(person: person)

        expect(result).to be false
      end

      example 'who is ineligible' do
        person.update!(eligible: false)
        account.reload
        expect(result).to be false
      end
    end # shared_examples

    context 'for a person' do
      let(:result) { described_class.new(person).create? }
      include_examples 'one person'
    end

    context 'for a solo account' do
      let(:result) { described_class.new(account).create? }
      include_examples 'one person'
    end

    context 'for a couples account' do
      let(:account) { create(:account, :couples, :eligible, :onboarded) }

      def result
        account.reload
        described_class.new(account).create?
      end

      example 'both ineligible' do
        account.people.each { |p| p.update!(eligible: false) }
        expect(result).to be false
      end

      # TODO move to sample data macros
      def complete_recs(account)
        run!(AdminArea::CardRecommendations::Complete, person_id: account.owner.id)
      end

      example 'returns true iff everyone can request' do
        expect(result).to be true

        # unresolved requests for either person = can't create
        create_rec_request('owner', account)
        expect(result).to be false
        complete_recs(account)

        create_rec_request('companion', account)
        expect(result).to be false
        complete_recs(account)

        create_rec_request('both', account.reload)
        expect(result).to be false
        complete_recs(account)

        expect(result).to be true

        # unresolved recs for either person = can't create
        rec_0 = create_rec(person: account.owner)
        expect(result).to be false

        rec_0.update!(applied_on: Date.today)
        rec_1 = create_rec(person: account.companion)
        expect(result).to be false

        decline_rec(rec_1)
        expect(result).to be true
      end
    end
  end
end
