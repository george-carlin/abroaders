require "rails_helper"

RSpec.describe InterestRegionsController do
  describe "GET #survey" do
    let(:account) { create(:account) }
    let(:owner)   { account.owner }
    before { sign_in account }

    subject { get :survey }

    context "when I haven't reached this survey page yet" do
      before { account.update_attributes!(onboarding_state: :travel_plan) }
      it { is_expected.to redirect_to new_travel_plan_path }
    end

    context "when I'm on the right survey page" do
      before { account.update_attributes!(onboarding_state: :regions_of_interest) }
      it { is_expected.to have_http_status(200) }
    end

    context "when I'm past this survey page" do
      before { account.update_attributes!(onboarding_state: :owner_balances) }
      it { is_expected.to redirect_to survey_person_balances_path(owner) }
    end

    context "when I have completed the entire survey" do
      before { account.update_attributes!(onboarding_state: :complete) }
      it { is_expected.to redirect_to root_path }
    end
  end
end
