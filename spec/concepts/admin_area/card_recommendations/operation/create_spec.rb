require 'rails_helper'

RSpec.describe AdminArea::CardRecommendations::Operation::Create do
  let(:op) { described_class }

  let(:product) { create(:product) }
  let(:offer)   { create(:offer, product: product) }
  let(:person)  { create(:person) }

  example 'valid recommendation' do
    result = op.(
      person_id: person.id,
      card_recommendation: {
        offer_id:  offer.id,
      },
    )
    expect(result.success?).to be true
    rec = result['model']
    expect(rec.offer).to eq offer
    expect(rec.product).to eq offer.product
    expect(rec.person).to eq person
    # TODO this should be a datetime, not a date! DATETIMEFIXME
    expect(rec.recommended_at).to eq Time.zone.now.to_date
    expect(rec.recommendation?).to be true
  end

  specify 'offer must be live' do
    # TODO replace with op
    offer.update!(killed_at: Time.zone.now)
    expect do
      result = op.(
        person_id: person.id,
        card_recommendation: {
          offer_id:  offer.id,
        },
      )
      expect(result.success?).to be false
      expect(result['errors']).to eq ["Couldn't find live offer with ID #{offer.id}"]
    end.not_to change { Card.recommendations.count }
  end
end
