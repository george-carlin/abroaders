require 'rails_helper'

RSpec.describe RecommendationRequest::Policy do
  let(:person) { create(:person, :eligible) }

  describe '#create?' do
    let(:result) { described_class.new(person).create? }

    example 'person has an unresolved rec request' do
      RecommendationRequest.create!(person: person) # USEOP
      expect(result).to be false
    end

    example 'person has a resolved rec request' do
      RecommendationRequest.create!(person: person, resolved_at: Time.now) # USEOP
      expect(result).to be true
    end

    example 'person has resolved recommendations' do
      create_card_recommendation(:applied, person: person)
      create_card_recommendation(:expired, person: person)
      create_card_recommendation(:pulled, person: person)

      # and create a declined one:
      run!(
        CardRecommendation::Operation::Decline,
        { id: create_rec(person: person).id, card: { decline_reason: 'X' } },
        'account' => person.account,
      )

      expect(result).to be true
    end

    example 'person has unresolved recommendations' do
      # same as the 'resolved' spec, plus one unresolved one
      create_card_recommendation(:applied, person: person)
      create_card_recommendation(:expired, person: person)
      create_card_recommendation(:pulled, person: person)

      # declined rec:
      run!(
        CardRecommendation::Operation::Decline,
        { id: create_rec(person: person).id, card: { decline_reason: 'X' } },
        'account' => person.account,
      )

      create_card_recommendation(person: person)

      expect(result).to be false
    end

    example 'person is ineligible' do
      person.update!(eligible: false)
      expect(result).to be false
    end
  end
end
