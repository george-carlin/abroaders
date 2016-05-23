require 'rails_helper'

describe CardAccount do

  let(:account)   { build(:account) }
  let(:person)    { account.people.first }
  let(:card)      { build(:card) }
  let(:offer)     { build(:offer, card: card) }
  let(:card_account) { described_class.from_survey.new(person: person) }

  describe "::Statuses" do
    before { card_account.offer = offer }

    describe "#decline_with_reason!" do
      let(:message) { "Blah blah blah" }
      before { card_account.decline_with_reason!(message) }

      it "sets the card account's status to 'declined'" do
        expect(card_account).to be_declined
      end

      it "sets 'declined_at' to today" do
        expect(card_account.declined_at).to eq Date.today
      end

      it "saves the decline reason" do
        expect(card_account.decline_reason).to eq message
      end
    end

    describe "SafetyChecks" do
      describe "#openable?" do
        it "is true iff the card card_account is not opened but can be" do
          card_account.status = :recommended
          expect(card_account.openable?).to be_truthy
          %i[declined denied open closed].each do |status|
            card_account.status = status
            expect(card_account.openable?).to be_falsey
          end
        end

        it "is aliased as 'acceptable?'" do
          card_account.status = :recommended
          expect(card_account.acceptable?).to be_truthy
          %i[declined denied open closed].each do |status|
            card_account.status = status
            expect(card_account.acceptable?).to be_falsey
          end
        end
      end

      describe "#applyable?" do
        it "is true if the person can apply for the card" do
          card_account.status = :recommended
          expect(card_account.applyable?).to be_truthy
          %i[declined denied open closed].each do |status|
            card_account.status = status
            expect(card_account.applyable?).to be_falsey
          end
        end
      end

      describe "#declinable?" do
        it "is true if the person can decline to apply for the card" do
          card_account.status = :recommended
          expect(card_account.declinable?).to be_truthy
          %i[declined denied open closed].each do |status|
            card_account.status = status
            expect(card_account.declinable?).to be_falsey
          end
        end
      end

      describe "#deniable?" do
        it "is true iff the card account is not denied but can be" do
          card_account.status = :recommended
          expect(card_account.deniable?).to be_truthy
          %i[declined denied open closed].each do |status|
            card_account.status = status
            expect(card_account.deniable?).to be_falsey
          end
        end
      end
    end

  end # ::Statuses

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

end
