require 'rails_helper'

RSpec.describe Card do
  let(:account) { Account.new }
  let(:person)  { account.build_owner }
  let(:product) { build(:card_product) }
  let(:offer)   { Offer.new(card_product: product) }
  let(:card) { described_class.new(person: person) }

  before { card.offer = offer }

  example "#recommended?" do
    card.recommended_at = nil
    expect(card.recommended?).to be false
    card.recommended_at = Time.current
    expect(card.recommended?).to be true
  end

  example "#declined?" do
    card.recommended_at = Time.current
    expect(card.declined?).to be false
    card.declined_at = Time.current
    expect(card.declined?).to be true
  end

  example "#denied?" do
    card.recommended_at = Time.current
    card.applied_on = Time.current
    card.denied_at = Time.current
    expect(card.denied?).to be true
  end

  example '#offer?' do
    card.offer = offer
    expect(card.offer?).to be true
    card.offer = nil
    expect(card.offer?).to be false
  end

  # Scopes

  describe '.recommended' do
    let(:product) { create(:card_product) }
    let(:offer) { create_offer(card_product: product) }
    let(:person) { create_person }

    # extend the macro so that we always use the same offer and person,
    # just to avoid making a bunch of unnecessary DB writes
    def create_rec(*args)
      overrides = args.last.is_a?(Hash) ? args.pop : {}
      traits    = args
      overrides[:offer]  = offer
      overrides[:person] = person

      super(*traits, overrides)
    end

    example '' do
      create_card_account
      returned = create_card_recommendation
      expect(described_class.recommended).to eq [returned]
    end

    example ".actionable" do
      # not actionable:
      create_rec(:approved)
      create_rec(:nudged, :denied)
      create_rec(:redenied)
      create_rec(:expired)
      create_card_account(card_product: product, person: person)
      decline_rec(create_rec)

      # open after reconsideration:
      create_rec(:denied, :called, :approved)
      # open after nudging:
      create_rec(:applied, :nudged, :approved)

      actionable = [
        # brand new:
        create_rec,
        # applied but pending:
        create_rec(:applied),
        # applied and nudged:
        create_rec(:applied, :nudged),
        # denied but reconsiderable:
        create_rec(:denied),
        # denied, called, pending:
        create_rec(:denied, :called),
      ]

      expect(Card.recommended.actionable).to match_array(actionable)
    end

    example ".unresolved" do
      # resolved:
      create_rec(:applied)
      create_rec(:expired)
      decline_rec(create_rec)

      # not a recommendation:
      create_card_account(card_product: product, person: person)

      unresolved = create_rec

      expect(Card.recommended.unresolved).to eq [unresolved]
    end
  end # .recommended
end
