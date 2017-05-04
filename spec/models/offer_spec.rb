require 'rails_helper'

RSpec.describe Offer do
  let(:offer) { described_class.new }

  example '#condition=' do
    # it raises an error when you try to set an invalid condition
    %w(
      on_approval
      on_first_purchase
      on_minimum_spend
      no_bonus
    ).each do |condition|
      expect { offer.condition = condition }.not_to raise_error
      expect(offer.condition).to eq condition
    end

    expect { offer.condition = 'invalid' }.to raise_error(Dry::Types::ConstraintError)
  end

  example '#partner=' do
    # it raises an error when you try to set an invalid condition
    %w(
      award_wallet
      card_benefit
      card_ratings
      credit_cards
      none
    ).each do |partner|
      expect { offer.partner = partner }.not_to raise_error
      expect(offer.partner).to eq partner
    end

    expect { offer.partner = 'invalid' }.to raise_error(Dry::Types::ConstraintError)
  end

  example '.recommendable & #recommendable?' do
    unknown = create(:card_product).unknown_offer
    live = create_offer
    dead = kill_offer(create_offer)

    scope = described_class.recommendable
    expect(scope.length).to eq 1
    expect(scope).not_to include dead
    expect(scope).not_to include unknown
    expect(scope).to include live

    expect(dead).not_to be_recommendable
    expect(live).to be_recommendable
    expect(unknown).not_to be_recommendable
  end
end
