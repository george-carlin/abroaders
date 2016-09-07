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
        expect(account.people.first.ready?).to be false
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
          expect(person.ready?).to be false
        end
      end

      context "and :onboarded_spending trait" do
        let(:traits) { [:with_companion, :onboarded_spending] }
        it "creates an account with two people and their spending" do
          expect(Account.count).to eq 1
          expect(Person.count).to eq 2
          expect(SpendingInfo.count).to eq 2
          account.people.each do |person|
            expect(person.onboarded_spending?).to be true
            expect(person.onboarded_cards?).to be false
            expect(person.onboarded_balances?).to be false
            expect(person.ready?).to be false
          end
        end
      end

      context "and :onboarded trait" do
        let(:traits) { [:with_companion, :onboarded] }
        it "creates an account with two onboarded (but unready) people" do
          expect(Account.count).to eq 1
          expect(Person.count).to eq 2
          expect(SpendingInfo.count).to eq 2
          account.people.each do |person|
            expect(person.onboarded_eligibility?).to be true
            expect(person.eligible?).to be true
            expect(person.onboarded_spending?).to be true
            expect(person.onboarded_cards?).to be true
            expect(person.onboarded_balances?).to be true
            expect(person.ready?).to be false
          end
          expect(account.onboarded?).to be true
        end
      end

      context "and :ready trait" do
        let(:traits) { [:with_companion, :ready] }
        it "creates an account with two onboarded and ready people" do
          expect(Account.count).to eq 1
          expect(Person.count).to eq 2
          expect(SpendingInfo.count).to eq 2
          account.people.each do |person|
            expect(person.onboarded_eligibility?).to be true
            expect(person.eligible?).to be true
            expect(person.onboarded_spending?).to be true
            expect(person.onboarded_cards?).to be true
            expect(person.onboarded_balances?).to be true
            expect(person.ready?).to be true
          end
          expect(account.onboarded?).to be true
        end
      end
    end

    context "with :onboarded_spending trait" do
      let(:traits) { [:onboarded_spending] }
      it "creates an account with one person and his spending" do
        expect(Account.count).to eq 1
        expect(Person.count).to eq 1
        expect(SpendingInfo.count).to eq 1
        account.people.each do |person|
          expect(person.onboarded_spending?).to be true
          expect(person.onboarded_eligibility?).to be true
          expect(person.eligible?).to be true
          expect(person.onboarded_cards?).to be false
          expect(person.onboarded_balances?).to be false
          expect(person.ready?).to be false
        end
      end
    end

    context "with :onboarded trait" do
      let(:traits) { [:onboarded] }
      it "creates an account with one onboarded (but unready) person" do
        expect(Account.count).to eq 1
        expect(Person.count).to eq 1
        expect(SpendingInfo.count).to eq 1
        account.people.each do |person|
          expect(person.onboarded_eligibility?).to be true
          expect(person.eligible?).to be true
          expect(person.onboarded_spending?).to be true
          expect(person.onboarded_cards?).to be true
          expect(person.onboarded_balances?).to be true
          expect(person.ready?).to be false
        end
        expect(account.onboarded?).to be true
      end
    end

    context "with :ready trait" do
      let(:traits) { [:ready] }
      it "creates an account with one onboarded and ready person" do
        expect(Account.count).to eq 1
        expect(Person.count).to eq 1
        expect(SpendingInfo.count).to eq 1
        person = account.people.first
        expect(person.onboarded_eligibility?).to be true
        expect(person.eligible?).to be true
        expect(person.onboarded_spending?).to be true
        expect(person.onboarded_cards?).to be true
        expect(person.onboarded_balances?).to be true
        expect(person.ready?).to be true
        expect(account.onboarded?).to be true
      end
    end
  end


  describe "person factory" do
    let(:create_person) { create(:person, *traits) }
    let(:traits) { [] }

    let(:person) { Person.last }

    it "creates a person with an account" do
      create_person
      expect(Account.count).to eq 1
      expect(Person.count).to eq 1
    end

    it "doesn't set the person's eligibilty" do
      create_person
      expect(Person.last.eligible).to be_nil
    end

    it "doesn't create any SpendingInfos" do
      expect{create_person}.not_to change{SpendingInfo.count}
    end

    context "with :eligible trait" do
      let(:traits) { :eligible }
      it "creates a person who is eligible to apply for cards" do
        create_person
        expect(person).to be_eligible
      end
    end

    context "with :ineligible trait" do
      let(:traits) { :ineligible }
      it "creates a person who is ineligible to apply for cards" do
        create_person
        expect(person.eligible).to be false
      end
    end

    context "with :onboarded_spending trait" do
      let(:traits) { :onboarded_spending }
      it "creates an eligible person with spending info" do
        create_person
        expect(Person.count).to eq 1
        expect(Account.count).to eq 1
        expect(SpendingInfo.count).to eq 1
        expect(person.spending_info).to be_present
        expect(person.spending_info).to be_persisted
        expect(person).to be_eligible
      end
    end

    context "with :onboarded trait" do
      let(:traits) { :onboarded }
      it "creates an onboarded but unready person" do
        create_person
        expect(Person.count).to eq 1
        expect(Account.count).to eq 1
        expect(SpendingInfo.count).to eq 1
        expect(person.spending_info).to be_present
        expect(person.spending_info).to be_persisted
        expect(person).to be_eligible
        expect(person.onboarded_eligibility?).to be true
        expect(person).to be_onboarded
        expect(person).not_to be_ready
      end
    end

    context "with :ready trait" do
      let(:traits) { :ready }
      it "creates an onboarded and ready person" do
        create_person
        expect(Person.count).to eq 1
        expect(Account.count).to eq 1
        expect(SpendingInfo.count).to eq 1
        expect(person.spending_info).to be_present
        expect(person.spending_info).to be_persisted
        expect(person).to be_eligible
        expect(person.onboarded_eligibility?).to be true
        expect(person).to be_onboarded
        expect(person).to be_ready
      end
    end
  end
end
