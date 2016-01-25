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

  end
end
