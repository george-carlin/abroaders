require 'rails_helper'

RSpec.describe Offer::Cell do
  let(:offer) { Offer.new }
  let(:cell)  { described_class.(offer) }

  example "#cost" do
    offer.cost = 250
    expect(cell.cost).to eq "$250.00"
  end

  describe "#description" do
    let(:description) { cell.description }

    before do
      offer.product = CardProduct.new(currency: Currency.new(name: "Dinero"))
      offer.points_awarded = 7_500
    end

    example 'points awarded on first purchase' do
      offer.condition = :on_first_purchase
      expect(description).to eq "7,500 Dinero points awarded upon making your first purchase using this card."
    end

    example 'points awarded on approval' do
      offer.condition = 'on_approval'
      expect(description).to eq "7,500 Dinero points awarded upon a successful application for this card."
    end

    example 'points application on minimum spend' do
      offer.condition = "on_minimum_spend"
      offer.spend = 4_500
      offer.days  = 40
      expect(description).to eq "Spend $4,500.00 within 40 days to receive a bonus of 7,500 Dinero points"
    end
  end

  example "#points_awarded" do
    offer.points_awarded = 15_000
    expect(cell.points_awarded).to eq '15,000'
  end

  example "#currency_name" do
    # minor code smell: introducing so many dependencies on Offer::Cell
    currency      = Currency.new(name: 'My currency')
    offer.product = CardProduct.new(currency: currency)
    expect(cell.currency_name).to eq 'My currency'
  end

  example '#spend' do
    offer.spend = 250
    expect(cell.spend).to eq "$250.00"
  end
end
