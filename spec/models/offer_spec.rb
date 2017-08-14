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

  example 'cards_count' do
    offer = create_offer
    expect(offer.cards_count).to eq 0
    rec_0 = create_card_recommendation(offer: offer)
    expect(offer.reload.cards_count).to eq 1
    rec_1 = create_card_recommendation(offer: offer)
    expect(offer.reload.cards_count).to eq 2
    rec_0.destroy
    expect(offer.reload.cards_count).to eq 1
    rec_1.destroy
    expect(offer.reload.cards_count).to eq 0
  end
end
