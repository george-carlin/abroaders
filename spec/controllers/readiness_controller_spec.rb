require "rails_helper"

describe ReadinessController do
  let(:account) { create(:account) }
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

  describe "GET #edit" do
    subject { get :edit }

    context 'for a couples account' do
      let(:account) { create(:couples_account, :onboarded) }
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

    context 'for a solo account' do
      let(:account) { create(:account, :onboarded) }
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
