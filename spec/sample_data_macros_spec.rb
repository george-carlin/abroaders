require 'rails_helper'

RSpec.describe SampleDataMacros do
  describe '#create_account' do
    it 'basic' do
      expect do
        account = create_account
        expect(account).to be_a(Account)
        expect(account.onboarding_state).to eq 'home_airports'
        expect(account.owner).not_to be_eligible
      end.to change { Account.count }.by(1).and(change { Person.count }.by(1))
    end

    it 'unique-emails' do
      accounts = Array.new(3) { create_account }
      expect(accounts.map(&:email).uniq.length).to eq 3
    end

    it 'with overrides' do
      account = create_account(
        email: 'george@george.com',
        onboarding_state: 'spending',
        monthly_spending_usd: 1234,
      )
      expect(account.email).to eq 'george@george.com'
      expect(account.onboarding_state).to eq 'spending'
      expect(account.monthly_spending_usd).to eq 1234
    end

    it 'onboarded' do
      expect do
        account = create_account(:onboarded)
        expect(account).to be_a(Account)
        expect(account).to be_onboarded
      end.to change { Account.count }.by(1).and(change { Person.count }.by(1))
    end

    it 'couples' do
      expect do
        account = create_account(:couples)
        expect(account).to be_a(Account)
        expect(account.couples?).to be true
        expect(account.owner).not_to be_eligible
        expect(account.companion).not_to be_eligible
      end.to change { Account.count }.by(1).and(change { Person.count }.by(2))
    end

    it 'eligible' do
      expect do
        account = create_account(:eligible)
        expect(account).to be_a(Account)
        expect(account.owner).to be_eligible
      end.to change { Account.count }.by(1).and(change { Person.count }.by(1))
    end

    it 'couples, eligible, onboarded' do # putting it all together
      expect do
        account = create_account(:eligible, :couples, :onboarded)
        expect(account).to be_a(Account)
        expect(account.couples?).to be true
        expect(account).to be_onboarded
        expect(account.owner).to be_eligible
        expect(account.companion).to be_eligible
      end.to change { Account.count }.by(1).and(change { Person.count }.by(2))
    end
  end

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
      expect { create_card_account(closed_on: Date.today) }.to change { Card.count }.by(1)
      expect(Card.last.closed_on).not_to be_nil
    end

    example 'specifying person who is owner' do
      owner = create_person
      expect do
        card = create_card_account(person: owner)
        expect(card).to be_a(Card)
      end.to change { owner.cards.count }.by(1)
      expect(Person.count).to eq 1 # doesn't create extra people as a side effect
    end

    example 'specifying person who is companion' do
      account   = create_account(:couples)
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
        rec = create_card_recommendation
        expect(rec.offer?).to be true
      end.to change { Card.recommended.count }.by(1)
      expect(Admin.count).to eq 1
      expect(Offer.count).to eq 1
    end

    example 'with :approved trait' do
      expect do
        create_card_recommendation(:approved)
      end.to change { Card.recommended.count }.by(1)
      rec = Card.recommended.last

      expect(rec).to be_applied
      expect(rec).to be_opened
    end

    example 'with :seen trait' do
      expect do
        create_card_recommendation(:seen)
      end.to change { Card.recommended.count }.by(1)
      rec = Card.recommended.last
      expect(rec).to be_seen
    end

    example 'with :clicked trait' do
      expect do
        create_card_recommendation(:clicked)
      end.to change { Card.recommended.count }.by(1)
      rec = Card.recommended.last
      expect(rec).to be_clicked
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
      account = create_account(:couples, :eligible, :onboarded)
      rec = create_card_recommendation(person: account.owner)
      expect(rec.person).to eq account.owner
      rec = create_card_recommendation(person: account.companion)
      expect(rec.person).to eq account.companion
    end
  end

  describe '#create_currency' do
    it '' do
      expect do
        currency = create_currency
        expect(currency).to be_a(Currency)
      end.to change { Currency.count }.by(1)
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
        offer = create_offer(card_product: card_product)
        expect(offer).to be_an(Offer)
        expect(offer.card_product).to eq card_product
      end.to change { Offer.count }.by(1)
      expect(CardProduct.count).to eq 1
    end

    example 'no bonus' do
      expect do
        offer = create_offer(condition: 'no_bonus')
        expect(offer).to be_an(Offer)
      end.to change { Offer.count }.by(1)
      expect(Offer.last.condition).to eq 'no_bonus'
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
      person = create_person
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

  describe '#create_person' do
    let(:run_macro) { create_person(*traits) }
    let(:traits) { [] }

    let(:person) { Person.last }

    it 'creates a person with an account' do
      expect do
        person = create_person
        expect(person).to be_a(Person)
        expect(person).not_to be_eligible
        expect(person.type).to eq 'owner'
      end.to change { Account.count }.by(1).and(change { Person.count }.by(1))
      expect(SpendingInfo.count).to eq 0
    end

    example 'with overrides' do
      expect do
        person = create_person(first_name: 'George')
        expect(person).to be_a(Person)
        expect(person.first_name).to eq 'George'
      end.to change { Account.count }.by(1).and(change { Person.count }.by(1))
    end

    example ':eligible' do
      expect do
        person = create_person(:eligible)
        expect(person).to be_a(Person)
        expect(person).to be_eligible
        expect(person.type).to eq 'owner'
      end.to change { Account.count }.by(1).and(change { Person.count }.by(1))
    end

    example ':companion' do
      expect do
        person = create_person(:companion)
        expect(person).to be_a(Person)
        expect(person.type).to eq 'companion'
      end.to change { Account.count }.by(1).and(change { Person.count }.by(2))
    end

    example '#create_companion alias' do
      expect do
        person = create_companion
        expect(person).to be_a(Person)
        expect(person.type).to eq 'companion'
      end.to change { Account.count }.by(1).and(change { Person.count }.by(2))
    end
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
