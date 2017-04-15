require "rails_helper"

module Estimates
  RSpec.describe FeesEstimate do
    before do
      @usa = Region.new(code: "US", name: 'U.S.A. (Continental 48)')
      @eu  = Region.new(code: "EU", name: "Europe")

      @fr = Country.new(parent: @eu,  name: "France")
      @us = Country.new(parent: @usa, name: "United States")
      @uk = Country.new(parent: @eu,  name: "United Kingdom")

      @cdg = Airport.new(parent: City.new(parent: @fr))
      @jfk = Airport.new(parent: City.new(parent: @us))
      @lhr = Airport.new(parent: City.new(parent: @uk))
    end

    def get_estimate(attrs)
      described_class.new(attrs)
    end

    example "non-US -> non-US estimates" do
      attrs = { from: @cdg, to: @lhr, type: "single", no_of_passengers: 1 }

      single_fee_low  = FeesEstimate::NON_US_SINGLE_FEES_MIN_USD
      single_fee_high = FeesEstimate::NON_US_SINGLE_FEES_MAX_USD

      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq single_fee_low
      expect(get_estimate(attrs).high).to eq single_fee_high
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq single_fee_low
      expect(get_estimate(attrs).high).to eq single_fee_high
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq single_fee_low
      expect(get_estimate(attrs).high).to eq single_fee_high

      attrs[:type] = "return"
      return_fee_low  = FeesEstimate::NON_US_RETURN_FEES_MIN_USD
      return_fee_high = FeesEstimate::NON_US_RETURN_FEES_MAX_USD
      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq return_fee_low
      expect(get_estimate(attrs).high).to eq return_fee_high
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq return_fee_low
      expect(get_estimate(attrs).high).to eq return_fee_high
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq return_fee_low
      expect(get_estimate(attrs).high).to eq return_fee_high
    end

    example "US -> US estimates" do
      attrs = { from: @jfk, to: @jfk, type: "single", no_of_passengers: 1 }

      single_fee = FeesEstimate::US_TO_US_SINGLE_FEES_USD
      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq single_fee
      expect(get_estimate(attrs).high).to eq single_fee
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq single_fee
      expect(get_estimate(attrs).high).to eq single_fee
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq single_fee
      expect(get_estimate(attrs).high).to eq single_fee

      attrs[:type] = "return"
      return_fee = FeesEstimate::US_TO_US_RETURN_FEES_USD
      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq return_fee
      expect(get_estimate(attrs).high).to eq return_fee
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq return_fee
      expect(get_estimate(attrs).high).to eq return_fee
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq return_fee
      expect(get_estimate(attrs).high).to eq return_fee
    end

    example "US <-> non-US estimates" do
      attrs = { from: @cdg, to: @jfk, type: "single" }
      attrs[:no_of_passengers] = 1

      # NB: estimates are rounded to the nearest $5
      #
      # current values in the CSV:
      #   EU,US,64,157,65,222,65,183
      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq 65
      expect(get_estimate(attrs).high).to eq 155
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq 65
      expect(get_estimate(attrs).high).to eq 220
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq 65
      expect(get_estimate(attrs).high).to eq 185

      attrs[:type] = "return"
      #   EU,US,64,157,65,222,65,183
      #   US,EU,28,157,28,198,28,183
      #   total:92,314,93,410,93,366
      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq 90
      expect(get_estimate(attrs).high).to eq 315
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq 95
      expect(get_estimate(attrs).high).to eq 420
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq 95
      expect(get_estimate(attrs).high).to eq 365

      attrs[:no_of_passengers] = 3
      attrs[:class_of_service] = "economy"
      expect(get_estimate(attrs).low).to eq 90 * 3
      expect(get_estimate(attrs).high).to eq 315 * 3
      attrs[:class_of_service] = "business_class"
      expect(get_estimate(attrs).low).to eq 95 * 3
      expect(get_estimate(attrs).high).to eq 420 * 3
      attrs[:class_of_service] = "first_class"
      expect(get_estimate(attrs).low).to eq 95 * 3
      expect(get_estimate(attrs).high).to eq 365 * 3
    end
  end
end
