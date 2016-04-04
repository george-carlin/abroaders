require 'rails_helper'

describe CardOffer do
  let(:offer) { described_class.new }

  describe "validations" do
    %i[cost points_awarded spend days].each do |attr|
      it do
        is_expected.to validate_numericality_of(attr)
                          .is_greater_than_or_equal_to(0)
                          .is_less_than_or_equal_to(POSTGRESQL_MAX_INT_VALUE)
      end
    end
  end

  describe "#identifier" do
    it "is generated deterministically from points, spend, & days" do
      offer.points_awarded = 10_000
      offer.spend = 4_000
      offer.days  = 90
      expect(offer.identifier).to eq "10/4/90"
    end

    it "uses a decimal point for inexact multiples of 1000" do
      offer.points_awarded = 10_250
      offer.spend = 4_500
      offer.days  = 40
      expect(offer.identifier).to eq "10.25/4.5/40"
    end
  end
end
