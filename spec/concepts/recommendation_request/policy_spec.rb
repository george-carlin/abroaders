require 'rails_helper'

RSpec.describe RecommendationRequest::Policy do
  include_context 'create_rec avoids extra records'

  let(:account) { create_account(:eligible, :onboarded) }
  let(:admin) { create_admin }
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
        run!(
          AdminArea::CardRecommendations::Complete,
          { person_id: person.id },
          'current_admin' => admin,
        )
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

    context 'for a solo account' do
      context 'testing the account' do
        let(:result) { described_class.new(account).create? }
        include_examples 'one person'
      end

      context 'testing the person' do
        let(:result) { described_class.new(person).create? }
        include_examples 'one person'
      end
    end

    context 'for a couples account' do
      let(:account) { create_account(:couples, :eligible, :onboarded) }
      let(:owner) { account.owner }
      let(:companion) { account.companion }

      context 'testing a person' do
        let(:result) { described_class.new(owner).create? }

        example 'who is ineligible' do
          owner.update!(eligible: false)
          expect(result).to be false
        end

        example 'who has an unresolved request' do
          create_rec_request('owner', account)
          expect(result).to be false
        end

        example 'who has an unresolved recommendation' do
          create_rec(person: owner)
          expect(result).to be false
        end

        example 'whose partner has an unresolved request' do
          create_rec_request('companion', account)
          expect(result).to be false
        end

        example 'whose partner has an unresolved recommendation' do
          create_rec(person: companion)
          expect(result).to be false
        end

        example 'when both people have an unresolved request' do
          create_rec_request('both', account)
          expect(result).to be false
        end

        example 'when neither person has unresolved reqs or recs' do
          # create some recs and reqs but resolve them:
          create_rec_request('both', account)
          complete_recs(account)
          create_rec(person: owner).update!(applied_on: Date.today)
          decline_rec(create_rec(person: companion))
          expect(result).to be true
        end
      end

      context 'testing the account' do
        def result
          account.reload
          described_class.new(account).create?
        end

        example 'both ineligible' do
          account.people.each { |p| p.update!(eligible: false) }
          expect(result).to be false
        end

        example 'one ineligible, other can request' do
          owner.update!(eligible: false)
          expect(result).to be true
          owner.update!(eligible: true)
          companion.update!(eligible: false)
          expect(result).to be true
        end

        example 'one ineligible, other has unresolved recs or requests' do
          companion.update!(eligible: false)
          rec = create_rec(person: owner)
          expect(result).to be false
          rec.update!(applied_on: Date.today)
          create_rec_request('owner', account)
          expect(result).to be false
          # resolving everything means they can request again:
          complete_recs(account)
          expect(result).to be true
        end

        example 'both eligible, one has unresolved recs or requests' do
          # can't make a request for the second person until the first person
          # has resolved everything

          # with unresolved recs:
          rec = create_rec(person: owner)
          expect(result).to be false
          decline_rec(rec)
          rec = create_rec(person: companion)
          expect(result).to be false
          rec.update!(applied_on: Date.today)
          expect(result).to be true # resolved again

          # with unresolved requests:
          create_rec_request('owner', account)
          expect(result).to be false

          complete_recs(account)
          create_rec_request('companion', account)
          expect(result).to be false

          complete_recs(account)
          create_rec_request('companion', account)
          expect(result).to be false

          complete_recs(account)
          expect(result).to be true # resolved again
        end
      end
    end
  end
end
