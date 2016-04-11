require 'rails_helper'

describe CardAccount do

  let(:account)   { build(:account) }
  let(:person)    { build(:person, account: account) }
  let(:card)      { build(:card) }
  let(:offer)     { build(:card_offer, card: card) }
  let(:card_account) { described_class.new(person: person) }

  describe "::Statuses" do
    before { card_account.offer = offer }

    describe "#applied_at" do
      subject { card_account.applied_at }

      before do
        @time = 5.minutes.ago
        card_account.applied_at = @time
      end

      context "when status is 'declined'" do
        before { card_account.status = :declined  }
        it { should be_nil }
      end

      context "when status is not declined" do
        before { card_account.status = :open  }
        it "returns the value of the 'applied_at' column" do
          should eq @time
        end
      end
    end

    describe "#declined_at" do
      subject { card_account.declined_at }

      before do
        @time = 5.minutes.ago
        card_account.applied_at = @time
      end

      context "when status is 'declined'" do
        before { card_account.status = :declined  }
        it "returns the value of the 'applied_at' column" do
          should eq @time
        end
      end

      context "when status is not declined" do
        before { card_account.status = :open  }
        it { should be_nil }
      end
    end

    describe "#decline_with_reason!" do
      let(:message) { "Blah blah blah" }
      before { card_account.decline_with_reason!(message) }

      it "sets the card account's status to 'declined'" do
        expect(card_account).to be_declined
      end

      it "sets 'declined_at' to the current time" do
        expect(card_account.declined_at).to be_within(5.seconds).of(Time.now)
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

  specify "exactly one of card and offer must be present" do
    def errors; card_account.tap(&:valid?).errors; end

    expect(errors[:card]).to include t("errors.messages.blank")
    card_account.offer = offer
    expect(errors[:card]).to be_empty
    card_account.card = card
    expect(errors[:card]).to include t("errors.messages.present")
    card_account.offer = nil
    expect(errors[:card]).to be_empty
  end

end
