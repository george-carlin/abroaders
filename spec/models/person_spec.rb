require 'rails_helper'

describe Person do
  let(:person) { described_class.new }

  describe "#has_recent_recommendation?" do
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
