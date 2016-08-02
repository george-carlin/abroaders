require "rails_helper"

describe OfferPresenter do
  let(:offer)         { Offer.new }
  subject(:presenter) { described_class.new(offer, view) }

  class ViewStub
    include ActionView::Helpers::NumberHelper
  end
  let(:view) { ViewStub.new }

  describe "#identifier" do
    subject { presenter.identifier }
    it "is generated deterministically from points, spend, & days" do
      offer.points_awarded = 10_000
      offer.spend = 4_000
      offer.days  = 90
      is_expected.to eq "10/4/90"
    end

    it "uses a decimal point for inexact multiples of 1000" do
      offer.points_awarded = 10_250
      offer.spend = 4_500
      offer.days  = 40
      is_expected.to eq "10.25/4.5/40"
    end

    context "when 'condition' is 'on approval'" do
      it "ignores spend and days and includes 'A'" do
        offer.condition = "on_approval"
        offer.points_awarded = 10_000
        is_expected.to eq "10/A"
      end
    end

    context "when 'condition' is 'on first purchase'" do
      it "ignores spend and days and includes 'P'" do
        offer.condition = "on_first_purchase"
        offer.points_awarded = 10_000
        is_expected.to eq "10/P"
      end
    end
  end

  describe "#description" do
    subject { presenter.description }

    before do
      offer.card = Card.new(currency: Currency.new(name: "Dinero"))
      offer.points_awarded = 7_500
    end

    context "when 'condition' is 'on first purchase'" do
      it "prints reasonable description" do
        offer.condition = "on_first_purchase"
        is_expected.to eq "7,500 Dinero points awarded upon making your first purchase using this card."
      end
    end

    context "when 'condition' is 'on approval'" do
      it "prints reasonable description" do
        offer.condition = "on_approval"
        is_expected.to eq "7,500 Dinero points awarded upon a successful application for this card."
      end
    end

    context "when 'condition' is 'on minimum spend'" do
      it "prints reasonable description" do
        offer.condition = "on_minimum_spend"
        offer.spend = 4_500
        offer.days  = 40
        is_expected.to eq "Spend $4,500.00 within 40 days to receive a bonus of 7,500 Dinero points"
      end
    end
  end

end
