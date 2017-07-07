require 'rails_helper'

RSpec.describe AdminArea::CardRecommendations::Create do
  let(:admin) { create_admin }

  let(:op) { described_class }

  let(:offer) { create_offer }
  let(:person) { create_person }

  example 'valid recommendation' do
    result = op.(
      {
        person_id: person.id,
        card: {
          offer_id:  offer.id,
        },
      },
      'current_admin' => admin,
    )
    expect(result.success?).to be true
    rec = result['model']
    expect(rec.offer).to eq offer
    expect(rec.card_product).to eq offer.card_product
    expect(rec.person).to eq person
    expect(rec.recommended_at).to be_within(5.seconds).of(Time.now)
    expect(rec.recommended_by).to eq admin
  end

  specify 'offer must be live' do
    kill_offer(offer)
    expect do
      result = op.(
        {
          person_id: person.id,
          card: {
            offer_id:  offer.id,
          },
        },
        'current_admin' => admin,
      )
      expect(result.success?).to be false
      expect(result['errors']).to eq ["Couldn't find live offer with ID #{offer.id}"]
    end.not_to change { Card.recommended.count }
  end
end
