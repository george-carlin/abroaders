require 'rails_helper'

RSpec.describe AdminArea::CardRecommendation::Operation::Create do
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
    # TODO this should be a datetime, not a date!
    expect(rec.recommended_at).to eq Time.zone.now.to_date
  end

  specify 'offer must be live' do
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
