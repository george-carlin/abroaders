require "rails_helper"

describe SpendingInfosController do
  describe "GET #survey" do
    let(:account) { create(:account) }
    let(:owner)   { account.owner }
    before { sign_in account }

    subject { get :survey }

    context "when I haven't reached this survey page yet" do
      before { account.update_attributes!(onboarding_state: :owner_balances) }
      it { is_expected.to redirect_to survey_person_balances_path(owner) }
    end

    context "when I am on this survey page" do
      before { account.update_attributes!(onboarding_state: :spending) }
      it { is_expected.to have_http_status(200) }
    end

    context "when I have completed this survey page" do
      before { account.update_attributes!(onboarding_state: :readiness) }
      it { is_expected.to redirect_to survey_readiness_path }
    end

    context "when I have completed the entire survey" do
      before { account.update_attributes!(onboarding_state: :complete) }
      it { is_expected.to redirect_to root_path }
    end
  end
end
