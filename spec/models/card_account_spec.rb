require 'rails_helper'

describe CardAccount do

  let(:user)    { build(:user) }
  let(:card)    { build(:card) }
  let(:account) { described_class.new(card: card, user: user) }

  describe "::Statuses" do

    describe "#applied_at" do
      subject { account.applied_at }

      before do
        @time = 5.minutes.ago
        account.applied_at = @time
      end

      context "when status is 'declined'" do
        before { account.status = :declined  }
        it { should be_nil }
      end

      context "when status is not declined" do
        before { account.status = :open  }
        it "returns the value of the 'applied_at' column" do
          should eq @time
        end
      end
    end

    describe "#declined_at" do
      subject { account.declined_at }

      before do
        @time = 5.minutes.ago
        account.applied_at = @time
      end

      context "when status is 'declined'" do
        before { account.status = :declined  }
        it "returns the value of the 'applied_at' column" do
          should eq @time
        end
      end

      context "when status is not declined" do
        before { account.status = :open  }
        it { should be_nil }
      end
    end

    describe "#decline!" do
      before { account.decline! }

      it "sets the account's status to 'declined'" do
        expect(account).to be_declined
      end

      it "sets 'declined_at' to the current time" do
        expect(account.declined_at).to be_within(5.seconds).of(Time.now)
      end
    end

    describe "SafetyChecks" do
      describe "#openable?" do
        it "is true iff the card account is not opened but can be" do
          account.status = :recommended
          expect(account.openable?).to be_truthy
          %i[declined denied open closed].each do |status|
            account.status = status
            expect(account.openable?).to be_falsey
          end
        end

        it "is aliased as 'acceptable?'" do
          account.status = :recommended
          expect(account.acceptable?).to be_truthy
          %i[declined denied open closed].each do |status|
            account.status = status
            expect(account.acceptable?).to be_falsey
          end
        end
      end

      describe "#applyable?" do
        it "is true if the user can apply for the card" do
          account.status = :recommended
          expect(account.applyable?).to be_truthy
          %i[declined denied open closed].each do |status|
            account.status = status
            expect(account.applyable?).to be_falsey
          end
        end
      end

      describe "#declinable?" do
        it "is true if the user can decline to apply for the card" do
          account.status = :recommended
          expect(account.declinable?).to be_truthy
          %i[declined denied open closed].each do |status|
            account.status = status
            expect(account.declinable?).to be_falsey
          end
        end
      end

      describe "#deniable?" do
        it "is true iff the card account is not denied but can be" do
          account.status = :recommended
          expect(account.deniable?).to be_truthy
          %i[declined denied open closed].each do |status|
            account.status = status
            expect(account.deniable?).to be_falsey
          end
        end
      end
    end

  end
end
