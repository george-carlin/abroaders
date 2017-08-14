require 'rails_helper'

RSpec.describe AdminArea::CardRecommendations::Create do
  let(:admin) { create_admin }

  let(:op) { described_class }

  let(:offer) { create_offer }
  let(:account) { create_account(:eligible, :onboarded) }
  let(:person) { account.owner }

  example 'valid recommendation' do
    result = op.(
      { person_id: person.id, card: { offer_id:  offer.id } },
      'current_admin' => admin,
    )
    expect(result.success?).to be true
    rec = result['model']
    expect(rec.offer).to eq offer
    expect(rec.card_product).to eq offer.card_product
    expect(rec.person).to eq person
    expect(rec.recommended_at).to be_within(5.seconds).of(Time.now)
    expect(rec.recommended_by).to eq admin
    expect(rec.recommendation_request_id).to be nil
  end

  example 'person has unresolved rec request' do
    create_rec_request('owner', account)
    rec_req = person.unresolved_recommendation_request
    result = op.(
      { person_id: person.id, card: { offer_id:  offer.id } },
      'current_admin' => admin,
    )
    expect(result.success?).to be true
    rec = result['model']
    expect(rec.recommendation_request).to eq rec_req
  end

  specify 'offer must be live' do
    kill_offer(offer)
    expect do
      result = op.(
        { person_id: person.id, card: { offer_id:  offer.id } },
        'current_admin' => admin,
      )
      expect(result.success?).to be false
      expect(result['errors']).to eq ["Couldn't find live offer with ID #{offer.id}"]
    end.not_to change { Card.recommended.count }
  end
end
