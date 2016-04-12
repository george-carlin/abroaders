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

end
