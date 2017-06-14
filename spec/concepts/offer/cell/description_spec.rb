require 'cells_helper'

RSpec.describe Offer::Cell::Description do
  describe '#show' do
    let(:currency) { Currency.new(name: 'Dinero') }
    let(:product)  { CardProduct.new(currency: currency) }

    let(:offer) { Offer.new(card_product: product, points_awarded: 7_500) }

    before do
      # this is necessary because ActiveRecord isn't smart enough for
      # offer.currency to work like you'd expect unless the records are saved.
      allow(offer).to receive(:currency).and_return(currency)
    end

    let(:rendered) { raw_cell(offer) }

    example 'points awarded on first purchase' do
      offer.condition = 'on_first_purchase'
      expect(rendered).to eq \
        '7,500 Dinero points awarded upon making your first purchase using this card.'
    end

    example 'points awarded on approval' do
      offer.condition = 'on_approval'
      expect(rendered).to eq \
        '7,500 Dinero points awarded upon a successful application for this card.'
    end

    example 'points awarded on minimum spend' do
      offer.condition = 'on_minimum_spend'
      offer.spend = 4_500
      offer.days  = 40
      expect(rendered).to eq \
        'Spend $4,500.00 within 40 days to receive a bonus of 7,500 Dinero points'
    end

    example 'no points awarded' do
      offer.condition = 'no_bonus'
      offer.points_awarded = nil
      expect(rendered).to eq ''
    end
  end
end
