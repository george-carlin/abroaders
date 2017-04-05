require 'rails_helper'

RSpec.describe SampleDataMacros do
  describe '#create_card_account' do
    example 'unspecified person' do
      expect do
        card = create_card_account
        expect(card).to be_a(Card)
      end.to change { Card.count }.by(1)
    end

    example 'closed card' do
      expect { create_card_account(:closed) }.to change { Card.count }.by(1)
      expect(Card.last.closed_on).not_to be_nil
    end

    example 'specifying person who is owner' do
      owner = create(:person, owner: true)
      expect do
        card = create_card_account(person: owner)
        expect(card).to be_a(Card)
      end.to change { owner.cards.count }.by(1)
    end

    example 'specifying person who is companion' do
      account   = create(:account, :couples)
      companion = account.companion
      expect do
        card = create_card_account(person: companion)
        expect(card).to be_a(Card)
      end.to change { companion.cards.count }.by(1)
    end
  end

  example '#create_offer' do
    expect do
      offer = create_offer
      expect(offer).to be_an(Offer)
    end.to change { Offer.count }.by(1)
  end
end
