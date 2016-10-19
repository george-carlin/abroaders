require "rails_helper"

module Estimates
  describe PointsEstimate do
    before do
      @eu = Region.new(code: "EU", name: "Europe")

      @fr = Country.new(parent: @eu)
      @uk = Country.new(parent: @eu)

      @cdg = Airport.new(parent: City.new(parent: @fr))
      @lhr = Airport.new(parent: City.new(parent: @uk))
    end

    # Note that these tests are based on the real points estimate data,
    # hardcoded in lib/data/points_estimates.csv. If we update the data, this
    # test will start failing.
    example "estimate methods" do
      estimate = PointsEstimate.new(from: @cdg, to: @lhr, type: "single")
      estimate.no_of_passengers = 1

      estimate.class_of_service = "economy"
      expect(estimate.low).to eq 10_000
      expect(estimate.high).to eq 15_000
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq 22_500
      expect(estimate.high).to eq 30_000
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq 30_000
      expect(estimate.high).to eq 45_000

      estimate.type = "return"
      estimate.class_of_service = "economy"
      expect(estimate.low).to eq 10_000 * 2
      expect(estimate.high).to eq 15_000 * 2
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq 22_500 * 2
      expect(estimate.high).to eq 30_000 * 2
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq 30_000 * 2
      expect(estimate.high).to eq 45_000 * 2

      estimate.no_of_passengers = 3
      estimate.class_of_service = "economy"
      expect(estimate.low).to eq 10_000 * 2 * 3
      expect(estimate.high).to eq 15_000 * 2 * 3
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq 22_500 * 2 * 3
      expect(estimate.high).to eq 30_000 * 2 * 3
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq 30_000 * 2 * 3
      expect(estimate.high).to eq 45_000 * 2 * 3
    end
  end
end
