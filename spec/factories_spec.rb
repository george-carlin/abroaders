require "rails_helper"

RSpec.describe "factories" do
  describe "account factory" do
    before { @account = create(:account, *traits, params) }
    let(:traits) { [] }
    let(:params) { {} }

    let(:account) { @account }

    describe "with no traits" do
      it "creates an account with an owner" do
        # get counts of the entire tables to make sure no extraneous objects
        # are being created:
        expect(Account.count).to eq 1
        expect(Person.count).to eq 1
        expect(SpendingInfo.count).to eq 0
        expect(account.owner).to be_present
      end
    end

    describe "with :couples trait" do
      let(:traits) { [:couples] }
      it "creates an account with a companion" do
        expect(Account.count).to eq 1
        expect(Person.count).to eq 2
        expect(SpendingInfo.count).to eq 0
        expect(account.owner).to be_present
        expect(account.companion).to be_present
      end

      context "and :onboarded trait" do
        let(:traits) { [:couples, :onboarded] }
        it "creates an onboarded account with a companion" do
          expect(Account.count).to eq 1
          expect(Person.count).to eq 2
          expect(account.onboarded?).to be true
        end
      end
    end

    context "with :onboarded trait" do
      let(:traits) { [:onboarded] }
      it "creates an onboarded account" do
        expect(Account.count).to eq 1
        expect(Person.count).to eq 1
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
      expect { create_person }.not_to change { SpendingInfo.count }
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
  end
end
