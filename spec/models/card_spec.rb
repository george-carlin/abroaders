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

  example ".recommendations" do
    create_card
    returned = create_card_recommendation
    expect(described_class.recommendations).to eq [returned]
  end

  example ".unresolved" do
    product = create(:card_product)
    offer   = create_offer(product: product)
    person  = create(:person)

    # resolved:
    create_card_recommendation(:approved,        offer_id: offer.id, person_id: person.id)
    create_card_recommendation(:pulled,          offer_id: offer.id, person_id: person.id)
    create_card_recommendation(:nudged, :denied, offer_id: offer.id, person_id: person.id)
    create_card_recommendation(:redenied,        offer_id: offer.id, person_id: person.id)
    create_card_recommendation(:expired,         offer_id: offer.id, person_id: person.id)
    create_card(product: product, person: person)
    declined = create_card_recommendation(product: product, person: person)
    run!(
      CardRecommendation::Operation::Decline,
      { id: declined.id, card: { decline_reason: 'X' } },
      'account' => person.account,
    )

    # open after reconsideration:
    create_card_recommendation(:denied, :called, :approved, offer_id: offer.id, person_id: person.id)
    # open after nudging:
    create_card_recommendation(:applied, :nudged, :approved, offer_id: offer.id, person_id: person.id)

    unresolved = [
      # brand new:
      create_card_recommendation(offer_id: offer.id, person_id: person.id),
      # applied but pending:
      create_card_recommendation(:applied, offer_id: offer.id, person_id: person.id),
      # applied and nudged:
      create_card_recommendation(:applied, :nudged, offer_id: offer.id, person_id: person.id),
      # denied but reconsiderable:
      create_card_recommendation(:denied, offer_id: offer.id, person_id: person.id),
      # denied, called, pending:
      create_card_recommendation(:denied, :called, offer_id: offer.id, person_id: person.id),
    ]

    expect(Card.unresolved).to match_array(unresolved)
  end
end
