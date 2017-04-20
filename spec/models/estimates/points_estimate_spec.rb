require "rails_helper"

module Estimates
  RSpec.describe PointsEstimate do
    before do
      @eu = Region.new(code: "EU", name: "Europe")

      @fr = Country.new(parent: @eu)
      @uk = Country.new(parent: @eu)

      @cdg = Airport.new(parent: City.new(parent: @fr))
      @lhr = Airport.new(parent: City.new(parent: @uk))
    end

    def get_estimate(attrs)
      described_class.new(attrs)
    end

    # Note that these tests are based on the real points estimate data,
    # hardcoded in lib/data/points_estimates.csv. If we update the data, this
    # test will start failing.
    example "estimate methods" do
      attrs = { from: @cdg, to: @lhr, type: "single" }
      attrs[:no_of_passengers] = 1

      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq 10_000
      expect(get_estimate(attrs).high).to eq 15_000
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq 22_500
      expect(get_estimate(attrs).high).to eq 30_000
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq 30_000
      expect(get_estimate(attrs).high).to eq 45_000

      attrs[:type] = "return"
      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq 10_000 * 2
      expect(get_estimate(attrs).high).to eq 15_000 * 2
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq 22_500 * 2
      expect(get_estimate(attrs).high).to eq 30_000 * 2
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq 30_000 * 2
      expect(get_estimate(attrs).high).to eq 45_000 * 2

      attrs[:no_of_passengers] = 3
      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq 10_000 * 2 * 3
      expect(get_estimate(attrs).high).to eq 15_000 * 2 * 3
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq 22_500 * 2 * 3
      expect(get_estimate(attrs).high).to eq 30_000 * 2 * 3
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq 30_000 * 2 * 3
      expect(get_estimate(attrs).high).to eq 45_000 * 2 * 3
    end
  end
end
