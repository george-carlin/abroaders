require "rails_helper"

describe ReadinessController do
  describe "GET #edit" do

    subject { get :edit }

    context "when account has companion" do
      let(:account) { create(:account, :with_companion, :onboarded_cards, :onboarded_balances) }
      before { sign_in account }

      context "when account owner and member are ineligible" do
        before do
          account.owner.update_attributes!(eligible: false)
          account.companion.update_attributes!(eligible: false)
        end
        it { is_expected.to redirect_to root_path }
      end

      context "when account owner and member are ready" do
        before do
          account.owner.update_attributes!(eligible: true, ready: true)
          account.companion.update_attributes!(eligible: true, ready: true)
        end
        it { is_expected.to redirect_to root_path }
      end
    end

    context "when account hasn't companion" do
      let(:account) { create(:account, :onboarded_cards, :onboarded_balances) }
      before { sign_in account }

      context "when account owner is ineligible" do
        before { account.owner.update_attributes!(eligible: false) }
        it { is_expected.to redirect_to root_path }
      end

      context "when account owner is already ready" do
        before { account.owner.update_attributes!(eligible: true, ready: true) }
        it { is_expected.to redirect_to root_path }
      end
    end
  end
end
