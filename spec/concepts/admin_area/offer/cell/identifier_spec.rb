require 'rails_helper'

RSpec.describe AdminArea::Offer::Cell::Identifier do
  let(:cell) { described_class }

  describe "#show" do
    let(:offer) { OpenStruct.new }
    let(:identifier) { cell.(offer).() }

    # default condition = on_minimum_spend
    before { offer.condition = 'on_minimum_spend' }

    it 'returns points/spend/days' do
      offer.points_awarded = 10_000
      offer.spend = 4_000
      offer.days  = 90
      expect(identifier).to eq "10/4/90"
    end

    it "uses a decimal point for inexact multiples of 1000" do
      offer.points_awarded = 10_250
      offer.spend = 4_500
      offer.days  = 40
      expect(identifier).to eq "10.25/4.5/40"
    end

    context "when 'condition' is 'on approval'" do
      it "ignores spend and days and includes 'A'" do
        offer.condition = "on_approval"
        offer.points_awarded = 10_000
        expect(identifier).to eq "10/A"
      end
    end

    context "when 'condition' is 'on first purchase'" do
      it "ignores spend and days and includes 'P'" do
        offer.condition = "on_first_purchase"
        offer.points_awarded = 10_000
        expect(identifier).to eq "10/P"
      end
    end
  end
end
