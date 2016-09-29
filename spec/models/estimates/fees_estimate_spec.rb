require "rails_helper"

module Estimates
  describe FeesEstimate do
    before do
      @usa = Region.new(code: "US", name: "United States (Continental 48)")
      @eu  = Region.new(code: "EU", name: "Europe")

      @fr = Country.new(parent: @eu,  name: "France")
      @us = Country.new(parent: @usa, name: "United States")
      @uk = Country.new(parent: @eu,  name: "United Kingdom")
    end

    example "non-US -> non-US estimates" do
      estimate = FeesEstimate.new(from: @fr, to: @uk, type: "single")

      single_fee_low  = FeesEstimate::NON_US_SINGLE_FEES_MIN_USD
      single_fee_high = FeesEstimate::NON_US_SINGLE_FEES_MAX_USD

      estimate.class_of_service = "economy"
      expect(estimate.low).to eq single_fee_low
      expect(estimate.high).to eq single_fee_high
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq single_fee_low
      expect(estimate.high).to eq single_fee_high
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq single_fee_low
      expect(estimate.high).to eq single_fee_high

      estimate.type = "return"
      return_fee_low  = FeesEstimate::NON_US_RETURN_FEES_MIN_USD
      return_fee_high = FeesEstimate::NON_US_RETURN_FEES_MAX_USD
      estimate.class_of_service = "economy"
      expect(estimate.low).to eq return_fee_low
      expect(estimate.high).to eq return_fee_high
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq return_fee_low
      expect(estimate.high).to eq return_fee_high
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq return_fee_low
      expect(estimate.high).to eq return_fee_high
    end

    example "US -> US estimates" do
      estimate = FeesEstimate.new(from: @us, to: @us, type: "single")

      single_fee = FeesEstimate::US_TO_US_SINGLE_FEES_USD
      estimate.class_of_service = "economy"
      expect(estimate.low).to eq single_fee
      expect(estimate.high).to eq single_fee
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq single_fee
      expect(estimate.high).to eq single_fee
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq single_fee
      expect(estimate.high).to eq single_fee

      estimate.type = "return"
      return_fee = FeesEstimate::US_TO_US_RETURN_FEES_USD
      estimate.class_of_service = "economy"
      expect(estimate.low).to eq return_fee
      expect(estimate.high).to eq return_fee
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq return_fee
      expect(estimate.high).to eq return_fee
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq return_fee
      expect(estimate.high).to eq return_fee
    end

    example "US <-> non-US estimates" do
      estimate = FeesEstimate.new(from: @fr, to: @us, type: "single")
      estimate.no_of_passengers = 1

      # NB: estimates are rounded to the nearest $5
      #
      # current values in the CSV:
      #   EU,US,64,157,65,222,65,183
      estimate.class_of_service = "economy"
      expect(estimate.low).to eq 65
      expect(estimate.high).to eq 155
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq 65
      expect(estimate.high).to eq 220
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq 65
      expect(estimate.high).to eq 185


      estimate.type = "return"
      #   EU,US,64,157,65,222,65,183
      #   US,EU,28,157,28,198,28,183
      #   total:92,314,93,410,93,366
      estimate.class_of_service = "economy"
      expect(estimate.low).to eq 90
      expect(estimate.high).to eq 315
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq 95
      expect(estimate.high).to eq 420
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq 95
      expect(estimate.high).to eq 365

      estimate.no_of_passengers = 3
      estimate.class_of_service = "economy"
      expect(estimate.low).to eq 90*3
      expect(estimate.high).to eq 315*3
      estimate.class_of_service = "business_class"
      expect(estimate.low).to eq 95*3
      expect(estimate.high).to eq 420*3
      estimate.class_of_service = "first_class"
      expect(estimate.low).to eq 95*3
      expect(estimate.high).to eq 365*3
    end
  end
end
