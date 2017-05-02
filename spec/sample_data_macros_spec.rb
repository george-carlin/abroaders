require 'rails_helper'

RSpec.describe SampleDataMacros do
  example '#create_admin' do
    admin = create_admin
    expect(Admin.count).to eq 1
    expect(admin).to be_an(Admin)

    # test it works more than once in the same example (i.e. the email
    # uniqueness validation doesn't fail the 2nd time.)
    admin = create_admin
    expect(Admin.count).to eq 2
    expect(admin).to be_an(Admin)
  end

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
      expect(Person.count).to eq 1 # doesn't create extra people as a side effect
    end

    example 'specifying person who is companion' do
      account   = create(:account, :couples)
      companion = account.companion
      expect do
        card = create_card_account(person: companion)
        expect(card).to be_a(Card)
      end.to change { companion.cards.count }.by(1)
      expect(Person.count).to eq 2 # doesn't create extra people as a side effect
    end
  end

  describe '#create_card_recommendation' do
    it '' do
      expect do
        create_card_recommendation
      end.to change { Card.recommended.count }.by(1)
      expect(Admin.count).to eq 1
    end

    example 'with :approved trait' do
      expect do
        create_card_recommendation(:approved)
      end.to change { Card.recommended.count }.by(1)
      rec = Card.recommended.last

      expect(rec).to be_applied
      expect(rec).to be_opened
    end

    example 'specifying admin' do
      admin = create_admin
      expect do
        rec = create_card_recommendation(admin: admin)
        expect(rec.recommended_by).to eq admin
      end.to change { Card.recommended.count }.by(1)
      expect(Admin.count).to eq 1
    end

    example 'specifying person' do
      account = create(:account, :couples, :eligible, :onboarded)
      rec = create_card_recommendation(person: account.owner)
      expect(rec.person).to eq account.owner
      rec = create_card_recommendation(person: account.companion)
      expect(rec.person).to eq account.companion
    end
  end

  describe '#create_offer' do
    it '' do
      expect do
        offer = create_offer
        expect(offer).to be_an(Offer)
      end.to change { Offer.count }.by(1)
      expect(CardProduct.count).to eq 1
    end

    example 'specifying product' do
      card_product = create(:card_product)
      expect do
        offer = create_offer(product: card_product)
        expect(offer).to be_an(Offer)
        expect(offer.product).to eq card_product
      end.to change { Offer.count }.by(1)
      expect(CardProduct.count).to eq 1
    end
  end

  describe '#create_balance' do
    example '' do
      expect do
        balance = create_balance
        expect(balance).to be_a(Balance)
      end.to change { Balance.count }.by(1)
    end

    example 'specifying person' do
      person = create(:person)
      expect do
        balance = create_balance(person: person)
        expect(balance).to be_an(Balance)
        expect(balance.person).to eq person
      end.to change { Balance.count }.by(1)
      expect(Balance.count).to eq 1
    end
  end

  example '#create_travel_plan' do
    expect do
      travel_plan = create_travel_plan
      expect(travel_plan).to be_an(TravelPlan)
    end.to change { TravelPlan.count }.by(1)
  end

  example '#kill_offer' do
    offer = create_offer
    result = kill_offer(offer)
    expect(result).to eq offer
    expect(result).to be_dead
  end

  example '#verify_offer' do
    offer = create_offer
    result = verify_offer(offer)
    expect(result).to eq offer
    expect(result.last_reviewed_at).to be_within(2.seconds).of(Time.now)
  end
end
