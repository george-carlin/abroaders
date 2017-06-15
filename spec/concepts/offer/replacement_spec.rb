require 'rails_helper'

RSpec.describe Offer::Replacement do
  let(:query) { described_class }
  let(:card_product) { create(:card_product) }

  let(:offer) { create_offer(attrs) }

  describe 'for an "on approval" offer' do
    let(:attrs) do
      {
        card_product: card_product,
        condition: 'on_approval',
        cost: 0,
        points_awarded: 10_000,
      }
    end

    before do # create offers that don't match:
      create_offer(attrs.merge(points_awarded: 9999))
      create_offer(attrs.except(:card_product))
      create_offer(attrs.merge(cost: 1))
      create_offer( # different condition:
        card_product: card_product,
        condition: 'on_minimum_spend',
      )
    end

    example 'no matches' do
      expect(query.(offer)).to be_nil
    end

    example 'find match' do
      other_offer = create_offer(attrs)
      expect(query.(offer)).to eq other_offer
      expect(query.(other_offer)).to eq offer
    end
  end

  describe 'for an "on first purchase" offer' do
    let(:attrs) do
      {
        card_product: card_product,
        condition: 'on_first_purchase',
        cost: 0,
        days: 90,
        points_awarded: 10_000,
      }
    end

    before do # create offers that don't match:
      create_offer(attrs.merge(cost: 1))
      create_offer(attrs.merge(days: 91))
      create_offer(attrs.merge(points_awarded: 10_001))
      create_offer( # different condition:
        card_product: card_product,
        condition: 'on_minimum_spend',
      )
      create_offer(attrs.except(:card_product))
    end

    example 'no matches' do
      expect(query.(offer)).to be_nil
    end

    example 'find match' do
      other_offer = create_offer(attrs)
      expect(query.(offer)).to eq other_offer
      expect(query.(other_offer)).to eq offer
    end
  end

  describe 'for an "on minimum spend" offer' do
    let(:attrs) do
      {
        card_product: card_product,
        condition: 'on_minimum_spend',
        cost: 0,
        days: 90,
        points_awarded: 10_000,
        spend: 3000,
      }
    end

    before do # create offers that don't match:
      create_offer(attrs.merge(days: 91))
      create_offer(attrs.merge(points_awarded: 10_001))
      create_offer(attrs.merge(cost: 1))
      create_offer( # wrong condition:
        card_product: card_product,
        condition: 'on_minimum_spend',
      )
      create_offer(attrs.except(:card_product))
    end

    example 'no matches' do
      expect(query.(offer)).to be_nil
    end

    example 'find match' do
      other_offer = create_offer(attrs)
      expect(query.(offer)).to eq other_offer
      expect(query.(other_offer)).to eq offer
    end
  end

  describe 'for a "no bonus" offer' do
    let(:attrs) do
      { card_product: card_product, condition: 'no_bonus', cost: 0 }
    end

    before do # create offers that don't match:
      create_offer(attrs.except(:card_product))
      create_offer(attrs.merge(cost: 1))
      create_offer( # wrong condition:
        card_product: card_product,
        condition: 'on_minimum_spend',
      )
    end

    example 'no matches' do
      expect(query.(offer)).to be_nil
    end

    example 'find match' do
      other_offer = create_offer(attrs)
      expect(query.(offer)).to eq other_offer
      expect(query.(other_offer)).to eq offer
    end
  end
end
