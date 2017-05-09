require "rails_helper"

RSpec.describe ReadinessController do
  let(:account) { create(:account, :eligible) }
  let(:owner)   { account.owner }
  before { sign_in account }

  describe "GET #survey" do
    subject { get :survey }

    context "when I haven't reached this survey page yet" do
      before { account.update_attributes!(onboarding_state: :eligibility) }
      it { is_expected.to redirect_to survey_eligibility_path }
    end

    context "when I am on this survey page" do
      before { account.update_attributes!(onboarding_state: :readiness) }
      it { is_expected.to have_http_status(200) }
    end

    context "when I have completed the survey" do
      before { account.update_attributes!(onboarding_state: :complete) }
      it { is_expected.to redirect_to root_path }
    end
  end
end
