require 'rails_helper'

RSpec.describe Card do
  let(:account) { build(:account) }
  let(:person)  { account.people.first }
  let(:product) { build(:card_product) }
  let(:offer)   { build(:offer, product: product) }
  let(:card) { described_class.from_survey.new(person: person) }

  before { card.offer = offer }

  describe "#from_survey?" do
    it "is true iff recommended_at is nil" do
      card.recommended_at = nil
      expect(card.from_survey?).to be true
      card.recommended_at = Time.current
      expect(card.from_survey?).to be false
    end
  end

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
          card.applied_at = Time.current
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
    card.applied_at = Time.current
    expect(card.denied?).to be false
    card.denied_at = Time.current
    expect(card.denied?).to be true
  end

  # Callbacks

  describe "before validation" do
    # TODO this shouldn't be handled by the model, do it in the Operation
    it "sets #product to #offer.product" do
      offer   = create(:offer)
      product = offer.product
      card = build(:card, product: nil, offer: offer)
      card.valid?
      expect(card.product_id).to eq product.id
    end
  end

  # Scopes

  example ".from_survey" do
    returned = create(:survey_card)
    create(:card_recommendation)
    expect(described_class.from_survey).to eq [returned]
  end

  example ".recommendations" do
    create(:survey_card)
    returned = create(:card_recommendation)
    expect(described_class.recommendations).to eq [returned]
  end

  example ".visible" do
    product = create(:card_product)
    offer   = create(:offer, product: product)
    person  = create(:person)
    visible = [
      create(:card_recommendation,            offer: offer, person: person),
      create(:card_recommendation, :clicked,  offer: offer, person: person),
      create(:card_recommendation, :open,     offer: offer, person: person),
      create(:card_recommendation, :closed,   offer: offer, person: person),
      create(:card_recommendation, :denied,   offer: offer, person: person),
      create(:card_recommendation, :seen,     offer: offer, person: person),
      create(:card_recommendation, :applied,  offer: offer, person: person),
      create(:card_recommendation, :redenied, offer: offer, person: person),
      create(:card_recommendation, :nudged,   offer: offer, person: person),
      create(:card_recommendation, :redenied, offer: offer, person: person),
    ]

    # invisible:
    create(:survey_card, product: product, person: person)
    create(:card_recommendation, :declined, offer: offer, person: person)
    create(:card_recommendation, :expired,  offer: offer, person: person)
    create(:card_recommendation, :pulled,   offer: offer, person: person)

    expect(described_class.visible).to match_array(visible)
  end

  example ".resolved + .unresolved" do
    product = create(:card_product)
    offer   = create(:offer, product: product)
    person  = create(:person)

    resolved = [
      create(:card_rec, :open,            offer: offer, person: person),
      create(:card_rec, :pulled,          offer: offer, person: person),
      create(:card_rec, :nudged, :denied, offer: offer, person: person),
      create(:card_rec, :redenied,        offer: offer, person: person),
      create(:card_rec, :expired,         offer: offer, person: person),
      # open after reconsideration:
      create(:card_rec, :denied, :called, :open, offer: offer, person: person),
      # open after nudging:
      create(:card_rec, :applied, :nudged, :open, offer: offer, person: person),
      # opened, then closed:
      create(:card_rec, :open, :closed, offer: offer, person: person),
    ]

    # irrelevant:
    create(:card, :survey, product: product, person: person)

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

    expect(Card.resolved).to match_array(resolved)
    expect(Card.unresolved).to match_array(unresolved)
  end

  example ".not_irreversibly_denied & .irreversibly_denied" do
    cp = create(:card_product)
    o  = create(:offer, product: cp)
    p  = create(:person)
    attrs = { offer: o, person: p }

    irreversibly_denied = [
      create(:card_rec, :applied, :nudged, :denied, attrs),
      create(:card_rec, :applied, :denied, :called, :redenied, attrs),
    ]

    # irrelevant:
    create(:survey_card)

    not_irreversibly_denied = [
      # denied but reconsiderable:
      create(:card_rec, :applied, :denied, attrs),
      create(:card_rec, :applied, :denied, :called, attrs),
      # not denied at all:
      create(:card_rec, :open,                    attrs),
      create(:card_rec, :pulled,                  attrs),
      create(:card_rec, :expired,                 attrs),
      create(:card_rec, :applied, :nudged, :open, attrs),
      create(:card_rec, :open, :closed,           attrs),
    ]

    expect(described_class.irreversibly_denied).to match_array(irreversibly_denied)
    expect(described_class.not_irreversibly_denied).to match_array(not_irreversibly_denied)
  end
end
