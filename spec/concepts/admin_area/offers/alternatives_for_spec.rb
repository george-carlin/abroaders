require 'rails_helper'

RSpec.describe AdminArea::Offers::AlternativesFor do
  let(:query) { described_class }
  let(:card_product) { create(:card_product) }

  let(:offer) { create_offer(attrs) } # default 'on_minimum_spend'

  # This macro assumes that the given offer is the only offer in the DB with
  # its given conditions, and:
  #
  # 1. Tests that the query returns no other offers
  # 1. Creates some sister offers with the same conditions but different values
  #    and affiliates (because the search doesn't care about those.)
  # 1. Tests that the query now returns the correct offers for every offer
  #    with this set of conditions
  #
  # Expect the 'attrs' let variable to be present, which contains
  # the attributes that can be used to create an identical offer.
  def test_offer(offer)
    # create a dead offer to make sure it's not returned:
    dead_alt = kill_offer(create_offer(attrs))

    # no matches:
    expect(query.(offer)).to eq []

    # save example matches:
    other_1 = create_offer(
      attrs.merge(
        partner: (Offer::Partner.values - [offer.partner]).sample,
        value: rand(10000),
      ),
    )
    other_2 = create_offer(
      attrs.merge(
        partner: (Offer::Partner.values - [offer.partner]).sample,
        value: rand(10000),
      ),
    )
    offers = [offer, other_1, other_2]
    offers.each do |o|
      expect(query.(o)).to match_array offers.dup.tap { |a| a.delete(o) }
    end

    # dead offer can be used for the query:
    expect(query.(dead_alt)).to match_array offers
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

    it { test_offer(offer) }
  end

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

    it { test_offer(offer) }
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

    it { test_offer(offer) }
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

    it { test_offer(offer) }
  end
end
