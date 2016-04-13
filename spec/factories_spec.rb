require "rails_helper"

describe "factories" do

  describe "account factory" do
    before { @account = create(:account, *traits, params) }
    let(:traits) { [] }
    let(:params) { {} }

    let(:account) { @account }

    describe "with no traits" do
      it "creates an account with one person" do
        # get counts of the entire tables to make sure no extraneous objects
        # are being created:
        expect(Account.count).to eq 1
        expect(Person.count).to eq 1
        expect(SpendingInfo.count).to eq 0
        expect(account.people.first.onboarded_spending?).to be false
        expect(account.people.first.onboarded_cards?).to be false
        expect(account.people.first.onboarded_balances?).to be false
        expect(account.people.first.ready_to_apply?).to be false
      end
    end

    describe "with :with_companion trait" do
      let(:traits) { [:with_companion] }
      it "creates an account with two people" do
        expect(Account.count).to eq 1
        expect(Person.count).to eq 2
        expect(SpendingInfo.count).to eq 0
        account.people.each do |person|
          expect(person.onboarded_spending?).to be false
          expect(person.onboarded_cards?).to be false
          expect(person.onboarded_balances?).to be false
          expect(person.ready_to_apply?).to be false
        end
      end

      context "and :with_spending trait" do
        let(:traits) { [:with_companion, :with_spending] }
        it "creates an account with two people and their spending" do
          expect(Account.count).to eq 1
          expect(Person.count).to eq 2
          expect(SpendingInfo.count).to eq 2
          account.people.each do |person|
            expect(person.onboarded_spending?).to be true
            expect(person.onboarded_cards?).to be false
            expect(person.onboarded_balances?).to be false
            expect(person.ready_to_apply?).to be false
          end
        end
      end

      context "and :onboarded trait" do
        let(:traits) { [:with_companion, :onboarded] }
        it "creates an account with two fully onboarded people" do
          expect(Account.count).to eq 1
          expect(Person.count).to eq 2
          expect(SpendingInfo.count).to eq 2
          expect(ReadinessStatus.count).to eq 2
          account.people.each do |person|
            expect(person.onboarded_spending?).to be true
            expect(person.onboarded_cards?).to be true
            expect(person.onboarded_balances?).to be true
            expect(person.ready_to_apply?).to be true
          end
          expect(account.onboarded?).to be true
        end
      end
    end

    context "with :with_spending trait" do
      let(:traits) { [:with_spending] }
      it "creates an account with one person and his spending" do
        expect(Account.count).to eq 1
        expect(Person.count).to eq 1
        expect(SpendingInfo.count).to eq 1
        account.people.each do |person|
          expect(person.onboarded_spending?).to be true
          expect(person.onboarded_cards?).to be false
          expect(person.onboarded_balances?).to be false
          expect(person.ready_to_apply?).to be false
        end
      end
    end

    context "with :onboarded trait" do
      let(:traits) { [:onboarded] }
      it "creates an account with one fully onboarded person" do
        expect(Account.count).to eq 1
        expect(Person.count).to eq 1
        expect(SpendingInfo.count).to eq 1
        expect(ReadinessStatus.count).to eq 1
        account.people.each do |person|
          expect(person.onboarded_spending?).to be true
          expect(person.onboarded_cards?).to be true
          expect(person.onboarded_balances?).to be true
          expect(person.ready_to_apply?).to be true
        end
        expect(account.onboarded?).to be true
      end
    end
  end


  describe "person factory" do
    it "creates a person with an account" do
      create(:person)
      expect(Account.count).to eq 1
      expect(Person.count).to eq 1
    end
  end
end
