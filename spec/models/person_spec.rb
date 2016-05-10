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

  describe "#onboarded_spending?" do
    it "returns true iff the person has saved their spending info" do
      expect(person.onboarded_spending?).to be false
      person.build_spending_info
      expect(person.onboarded_spending?).to be false
      allow(person.spending_info).to receive(:persisted?) { true }
      expect(person.onboarded_spending?).to be true
    end
  end

  describe "#onboarded?" do
    subject { person.onboarded? }

    context "when the person hasn't given their eligibilty" do
      it { is_expected.to be false }

      context "and has onboarded balances" do
        before { person.onboarded_balances = true }
        it { is_expected.to be false }
      end
    end

    context "when the person is eligible to apply for cards" do
      before do
        allow(person).to receive(:onboarded_eligibility?) { true }
        allow(person).to receive(:eligible_to_apply?) { true }
      end

      it "returns true iff they have completed the onboarding survey" do
        expect(person).not_to be_onboarded
        allow(person).to receive(:onboarded_spending?).and_return(true)
        expect(person).not_to be_onboarded
        person.onboarded_cards = true
        expect(person).not_to be_onboarded
        person.onboarded_balances = true
        expect(person).not_to be_onboarded
        # Don't care if the user is ready:
        person.build_readiness_status(ready: false)
        allow(person.readiness_status).to receive(:persisted?) { true }
        expect(person).to be_onboarded
        person.readiness_status.ready = true
        expect(person).to be_onboarded
      end
    end


    context "when the person is ineligible to apply for cards" do
      before do
        allow(person).to receive(:onboarded_eligibility?) { true }
        allow(person).to receive(:eligible_to_apply?) { false }
      end

      it "returns true iff they have added their balances" do
        expect(person).not_to be_onboarded
        person.onboarded_balances = true
        expect(person).to be_onboarded
      end
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
