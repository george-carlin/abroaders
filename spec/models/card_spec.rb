require 'rails_helper'

RSpec.describe Card do
  let(:account) { Account.new }
  let(:person)  { account.build_owner }
  let(:product) { build(:card_product) }
  let(:offer)   { Offer.new(card_product: product) }
  let(:card) { described_class.new(person: person) }

  before { card.offer = offer }

  example "#recommended?" do
    expect(card.recommended?).to be false
    card.recommended_at = Time.current
    expect(card.recommended?).to be true
  end

  shared_examples "applyable?" do
    before { skip 'TODO' } # this is all way out of date
    subject { card.send(method) }

    context "when card is from survey" do
      before { card.recommended_at = nil }
      it { is_expected.to be false }
    end

    context "when card is a recommendation" do
      before { card.recommended_at = Time.current }

      context "and status is 'recommended'" do
        it "returns true" do
          raise unless card.status == "recommended" # sanity check
          expect(card.send(method)).to be true
        end
      end

      context "and status is not 'recommended' or" do
        it "returns false" do
          card.applied_on = Time.current
          raise if card.status == "recommended" # sanity check
          expect(card.send(method)).to be false
        end
      end
    end
  end

  describe "#applyable?" do
    let(:method) { :applyable? }
    include_examples "applyable?"
  end

  # For the time being, 'declinable?', 'openable?' and 'denyable?' are all
  # functionally equivalent to 'applyable?'. This will change when we add the
  # 'call the bank' mechanism

  describe "#declinable?" do
    let(:method) { :declinable? }
    include_examples "applyable?"
  end

  describe "#openable?" do
    let(:method) { :openable? }
    include_examples "applyable?"
  end

  describe "#deniable?" do
    let(:method) { :deniable? }
    include_examples "applyable?"
  end

  describe "#pendingable?" do
    let(:method) { :pendingable? }
    include_examples "applyable?"
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
    expect(card.denied?).to be false
    card.denied_at = Time.current
    expect(card.denied?).to be true
  end

  # Callbacks

  example "set #card_product to #offer.card_product before save" do
    offer   = create_offer
    product = offer.card_product
    card = Card.new(card_product: nil, offer: offer, person: create_person)
    card.save!
    expect(card.card_product_id).to eq product.id
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
