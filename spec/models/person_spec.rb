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

  describe "#onboarded_eligibility?" do
    it "returns true iff eligible is not nil" do
      person.eligible = nil
      expect(person.onboarded_eligibility?).to be false
      person.eligible = false
      expect(person.onboarded_eligibility?).to be true
      person.eligible = true
      expect(person.onboarded_eligibility?).to be true
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
      before { person.eligible = nil }

      it { is_expected.to be false }

      context "and has onboarded balances" do
        before { person.onboarded_balances = true }
        it { is_expected.to be false }
      end
    end

    context "when the person is eligible to apply for cards" do
      before { person.eligible = true }

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
      before { person.eligible = false }

      it "returns true iff they have added their balances" do
        expect(person).not_to be_onboarded
        person.onboarded_balances = true
        expect(person).to be_onboarded
      end
    end
  end

end
