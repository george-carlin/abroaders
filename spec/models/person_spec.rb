require 'rails_helper'

describe Person do
  let(:person) { described_class.new }

  describe "before save" do
    let(:person) { build(:person) }

    it "strips trailing whitespace from first_name" do
      person.first_name= "    string    "
      person.save!
      expect(person.first_name).to eq "string"
    end
  end

  describe "#onboarded?" do
    it "returns true if this person is fully onboarded" do
      expect(person).not_to be_onboarded
      allow(person).to receive(:onboarded_spending?).and_return(true)
      expect(person).not_to be_onboarded
      person.onboarded_cards = true
      expect(person).not_to be_onboarded
      person.onboarded_balances = true
      expect(person).not_to be_onboarded
      allow(person).to receive(:ready_to_apply?).and_return(true)
      expect(person).to be_onboarded
    end
  end

  describe "#recommend_offer!" do
    let(:offer)  { create(:offer) }
    let(:card)   { offer.card }
    let(:person) { create(:person) }

    it "creates a card/offer recommendation for the person" do
      expect do
        person.recommend_offer!(offer)
      end.to change{person.card_accounts.count}.by(1)
      rec = person.card_accounts.last
      expect(rec).to be_recommended
      expect(rec.source).to eq "recommendation"
      expect(rec.card).to eq card
      expect(rec.offer).to eq offer
      expect(rec.recommended_at).to be_within(5.seconds).of(Time.now)

      expect(person.card_recommendations).to include rec
    end
  end

end
