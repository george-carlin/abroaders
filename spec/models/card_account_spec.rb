require 'rails_helper'

describe CardAccount do

  let(:account)   { build(:account) }
  let(:person)    { account.people.first }
  let(:card)      { build(:card) }
  let(:offer)     { build(:offer, card: card) }
  let(:card_account) { described_class.from_survey.new(person: person) }

  before { card_account.offer = offer }

  describe "#from_survey?" do
    it "is true iff recommended_at is nil" do
      card_account.recommended_at = nil
      expect(card_account.from_survey?).to be true
      card_account.recommended_at = Time.now
      expect(card_account.from_survey?).to be false
    end
  end

  describe "#recommendation?" do
    it "is true iff recommended_at is not nil" do
      card_account.recommended_at = nil
      expect(card_account.recommendation?).to be false
      card_account.recommended_at = Time.now
      expect(card_account.recommendation?).to be true
    end
  end

  shared_examples "applyable?" do
    subject { card_account.send(method) }

    context "when card is from survey" do
      before { card_account.recommended_at = nil }
      it { is_expected.to be false }
    end

    context "when card is a recommendation" do
      before { card_account.recommended_at = Time.now }

      context "and status is 'recommended'" do
        it "returns true" do
          raise unless card_account.status == "recommended" # sanity check
          expect(card_account.send(method)).to be true
        end
      end

      context "and status is not 'recommended' or" do
        it "returns false" do
          card_account.applied_at = Time.now
          raise if card_account.status == "recommended" # sanity check
          expect(card_account.send(method)).to be false
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

  specify "card_id must match offer.card_id" do
    def errors; card_account.tap(&:valid?).errors; end

    msg = t("activerecord.errors.models.card_account.attributes.card.doesnt_match_offer")

    # no card or offer:
    expect(errors[:card]).not_to include(msg)
    # no offer:
    card_account.card = card
    expect(errors[:card]).not_to include(msg)
    # offer with no card
    card_account.card  = nil
    card_account.offer = Offer.new
    expect(errors[:card]).not_to include(msg)
    # mismatching card:
    card_account.card = Card.new
    expect(errors[:card]).to include(msg)
    # correct card
    card_account.offer.card = card_account.card
    expect(errors[:card]).not_to include(msg)
  end

  example "#recommended?" do
    card_account.recommended_at = Time.now
    expect(card_account.recommended?).to be true
    card_account.declined_at = Time.now
    expect(card_account.recommended?).to be false
  end

  example "#declined?" do
    card_account.recommended_at = Time.now
    expect(card_account.declined?).to be false
    card_account.declined_at = Time.now
    expect(card_account.declined?).to be true
  end

  example "#denied?" do
    card_account.recommended_at = Time.now
    card_account.applied_at = Time.now
    expect(card_account.denied?).to be false
    card_account.denied_at = Time.now
    expect(card_account.denied?).to be true
  end

  # Callbacks

  describe "before validation" do
    it "sets #card to #offer.card" do
      offer = create(:offer)
      card  = offer.card
      card_account = build(:card_account, card: nil, offer: offer)
      card_account.valid?
      expect(card_account.card_id).to eq card.id
    end
  end

  # Source

  describe "scopes" do
    before do
      @ca_0 = create(:survey_card_account)
      @ca_1 = create(:card_recommendation)
    end

    describe ".from_survey" do
      it "returns accounts where recommended_at is nil" do
        expect(described_class.from_survey).to eq [@ca_0]
      end
    end

    describe ".recommendations" do
      it "returns accounts where recommended_at is not nil" do
        expect(described_class.recommendations).to eq [@ca_1]
      end
    end
  end
end
