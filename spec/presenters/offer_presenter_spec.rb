require "rails_helper"

RSpec.describe OfferPresenter do
  let(:offer)         { Offer.new }
  subject(:presenter) { described_class.new(offer, view) }

  class ViewStub
    include ActionView::Helpers::NumberHelper
  end
  let(:view) { ViewStub.new }

  describe "#description" do
    subject(:description) { presenter.description }

    before do
      offer.product = CardProduct.new(currency: Currency.new(name: "Dinero"))
      offer.points_awarded = 7_500
    end

    context "when 'condition' is 'on first purchase'" do
      it "prints reasonable description" do
        offer.condition = "on_first_purchase"
        expect(description).to eq "7,500 Dinero points awarded upon making your first purchase using this card."
      end
    end

    context "when 'condition' is 'on approval'" do
      it "prints reasonable description" do
        offer.condition = "on_approval"
        expect(description).to eq "7,500 Dinero points awarded upon a successful application for this card."
      end
    end

    context "when 'condition' is 'on minimum spend'" do
      it "prints reasonable description" do
        offer.condition = "on_minimum_spend"
        offer.spend = 4_500
        offer.days  = 40
        expect(description).to eq "Spend $4,500.00 within 40 days to receive a bonus of 7,500 Dinero points"
      end
    end
  end
end
