require 'rails_helper'

RSpec.describe Card do
  let(:account) { build(:account) }
  let(:person)  { account.people.first }
  let(:product) { build(:card_product) }
  let(:offer)   { Offer.new(product: product) }
  let(:card) { described_class.non_recommendation.new(person: person) }

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

  specify "product_id must match offer.product_id" do
    def errors
      card.tap(&:valid?).errors
    end

    msg = t("activerecord.errors.models.card.attributes.product.doesnt_match_offer")

    # no card_product or offer:
    expect(errors[:product]).not_to include(msg)
    # no offer:
    card.product = product
    expect(errors[:product]).not_to include(msg)
    # offer with no card
    card.product = nil
    card.offer = Offer.new
    expect(errors[:product]).not_to include(msg)
    # mismatching product:
    card.product = CardProduct.new
    expect(errors[:product]).to include(msg)
    # correct product
    card.offer.product = card.product
    expect(errors[:product]).not_to include(msg)
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

  describe "before validation" do
    # TODO this shouldn't be handled by the model, do it in the Operation
    it "sets #product to #offer.product" do
      offer   = create_offer
      product = offer.product
      card = build(:card, product: nil, offer: offer)
      card.valid?
      expect(card.product_id).to eq product.id
    end
  end

  # Scopes

  example ".non_recommendation" do
    returned = create(:card)
    create(:card_recommendation)
    expect(described_class.non_recommendation).to eq [returned]
  end

  example ".recommendations" do
    create(:card)
    returned = create(:card_recommendation)
    expect(described_class.recommendations).to eq [returned]
  end

  example ".unresolved" do
    product = create(:card_product)
    offer   = create_offer(product: product)
    person  = create(:person)

    # resolved:
    create(:card_rec, :approved,        offer: offer, person: person)
    create(:card_rec, :pulled,          offer: offer, person: person)
    create(:card_rec, :nudged, :denied, offer: offer, person: person)
    create(:card_rec, :redenied,        offer: offer, person: person)
    create(:card_rec, :expired,         offer: offer, person: person)
    create(:card, :open, product: product, person: person)
    # open after reconsideration:
    create(:card_rec, :denied, :called, :approved, offer: offer, person: person)
    # open after nudging:
    create(:card_rec, :applied, :nudged, :approved, offer: offer, person: person)

    unresolved = [
      # brand new:
      create(:card_rec,            offer: offer, person: person),
      # applied but pending:
      create(:card_rec, :applied,  offer: offer, person: person),
      # applied and nudged:
      create(:card_rec, :applied, :nudged, offer: offer, person: person),
      # denied but reconsiderable:
      create(:card_rec, :denied, offer: offer, person: person),
      # denied, called, pending:
      create(:card_rec, :denied, :called, person: person),
    ]

    expect(Card.unresolved).to match_array(unresolved)
  end
end
