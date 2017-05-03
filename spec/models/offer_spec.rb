require 'rails_helper'

RSpec.describe Offer do
  let(:offer) { described_class.new }

  example '#condition=' do
    # it raises an error when you try to set an invalid condition
    %w(
      on_approval
      on_first_purchase
      on_minimum_spend
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
end
