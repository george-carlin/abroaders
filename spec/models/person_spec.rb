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

  describe "#has_recent_recommendation??" do
    it "returns true iff user has no card recommendation for the last 30 days" do
      person.last_recommendations_at = nil
      expect(person.has_recent_recommendation?).to be false
      person.last_recommendations_at = Time.current - 40.days
      expect(person.has_recent_recommendation?).to be false
      person.last_recommendations_at = Time.current
      expect(person.has_recent_recommendation?).to be true
    end
  end

end
