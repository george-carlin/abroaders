require 'rails_helper'

RSpec.describe CardApplication do
  describe "#card_recommendation=" do
    let(:app) { CardApplication.new }
    let(:rec) { CardRecommendation.new }

    example "when the card rec has no offer or person" do
      app.card_recommendation = rec
      # it doesn't set any offer or person:
      expect(app.offer).to be nil
      expect(app.person).to be nil
      expect(app.card_recommendation).to eq rec
    end

    example "when the rec has an offer and person and the app doesn't" do
      rec.person = person = Person.new
      rec.offer  = offer  = Offer.new
      app.card_recommendation = rec
      # it updates the app's offer and person:
      expect(app.person).to eq person
      expect(app.offer).to eq offer
      expect(app.card_recommendation).to eq rec
    end

    example "when the app has an offer and person and the rec doesn't" do
      app.person = person = Person.new
      app.offer  = offer  = Offer.new
      app.card_recommendation = rec
      # hmmmm... should this change the rec's offer or not? the method may be doing too much
      skip
      expect(rec.person).to eq person
      expect(rec.offer).to eq offer
      expect(app.card_recommendation).to eq rec
    end

    example "when the card rec has a different person to the app" do
      app.person = Person.new
      rec.person = Person.new
      expect { app.card_recommendation = rec }.to raise_error RuntimeError
      expect(app.card_recommendation).to be nil
    end

    example 'when the card rec has a different offer to the app' do
      app.offer = Offer.new
      rec.offer = Offer.new
      expect { app.card_recommendation = rec }.to raise_error RuntimeError
      expect(app.card_recommendation).to be nil
    end
  end
end
