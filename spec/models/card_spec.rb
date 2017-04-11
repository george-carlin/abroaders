require 'rails_helper'

RSpec.describe Card do
  let(:account) { build(:account) }
  let(:person)  { account.people.first }
  let(:product) { build(:card_product) }
  let(:offer)   { Offer.new(product: product) }
  let(:card) { described_class.new(person: person) }

  before { card.offer = offer }

  describe "#recommendation?" do
    it "is true iff recommended_at is not nil" do
      card.recommended_at = nil
      expect(card.recommendation?).to be false
      card.recommended_at = Time.current
      expect(card.recommendation?).to be true
    end
  end

  shared_examples "applyable?" do
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

  example "#recommended?" do
    card.recommended_at = Time.current
    expect(card.recommended?).to be true
    card.declined_at = Time.current
    expect(card.recommended?).to be false
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

  example "set  #product to #offer.product before save" do
    offer   = create_offer
    product = offer.product
    card = Card.new(product: nil, offer: offer, person: create(:person))
    card.save!
    expect(card.product_id).to eq product.id
  end

  # Scopes

  describe '.recommended' do
    let(:product) { create(:card_product) }
    let(:offer) { create_offer(product: product) }
    let(:person) { create(:person) }

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
      create_rec(:pulled)
      create_rec(:nudged, :denied)
      create_rec(:redenied)
      create_rec(:expired)
      create_card_account(product: product, person: person)
      declined = create_rec
      run!(
        CardRecommendation::Operation::Decline,
        { id: declined.id, card: { decline_reason: 'X' } },
        'account' => person.account,
      )

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
      create_rec(:pulled)
      create_rec(:applied)
      create_rec(:expired)
      declined = create_rec
      run!(
        CardRecommendation::Operation::Decline,
        { id: declined.id, card: { decline_reason: 'X' } },
        'account' => person.account,
      )

      # not a recommendation:
      create_card_account(product: product, person: person)

      unresolved = create_rec

      expect(Card.recommended.unresolved).to eq [unresolved]
    end
  end
end
