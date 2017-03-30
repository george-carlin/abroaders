require 'rails_helper'

RSpec.describe SampleDataMacros do
  example "#create_card_recommendation" do
    expect { create_card_recommendation }.to change { CardRecommendation.count }.by(1)
  end

  example '#create_card' do
    expect do
      card = create_card
      expect(card).to be_a(Card)
    end.to change { Card.count }.by(1)

    expect { create_card(:closed) }.to change { Card.count }.by(1)
    expect(Card.last.closed_on).not_to be_nil
  end

  example '#create_offer' do
    expect do
      offer = create_offer
      expect(offer).to be_an(Offer)
    end.to change { Offer.count }.by(1)
  end
end
