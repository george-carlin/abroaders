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

  describe 'card product factory' do
    it '' do
      expect { create(:card_product) }.to change { CardProduct.count }.by(1)
    end
  end
end
