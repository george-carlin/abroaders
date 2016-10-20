require "rails_helper"

describe EligibilitiesController do
  describe "GET #survey" do
    let(:account) { create(:account) }
    before { sign_in account }

    subject { get :survey }

    context "when I haven't reached this survey page yet" do
      before { account.update_attributes!(onboarding_state: :account_type) }
      it { is_expected.to redirect_to type_account_path }
    end

    context "when I am on this survey page" do
      before { account.update_attributes!(onboarding_state: :eligibility) }
      it { is_expected.to have_http_status(200) }
    end

    context "when I have completed this survey page" do
      before { account.update_attributes!(onboarding_state: :owner_balances) }
      it { is_expected.to redirect_to survey_person_balances_path(account.owner) }
    end

    context "when I have completed the entire survey" do
      before { account.update_attributes!(onboarding_state: :complete) }
      it { is_expected.to redirect_to root_path }
    end
  end
end
