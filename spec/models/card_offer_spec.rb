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

  describe "#condition" do
    it "is 'on minimum spend' by default" do
      expect(offer).to be_on_minimum_spend
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

    context "when 'condition' is 'on approval'" do
      it "ignores spend and days and includes 'A'" do
        offer.condition = "on_approval"
        offer.points_awarded = 10_000
        expect(offer.identifier).to eq "10/A"
      end
    end

    context "when 'condition' is 'on first purchase'" do
      it "ignores spend and days and includes 'P'" do
        offer.condition = "on_first_purchase"
        offer.points_awarded = 10_000
        expect(offer.identifier).to eq "10/P"
      end
    end
  end
end
