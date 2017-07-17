require "rails_helper"

RSpec.describe AccountsController do
  describe "GET #type" do
    let(:account) { create_account }
    before { sign_in account }

    subject { get :type }

    context "when I haven't reached this survey page yet" do
      before { account.update!(onboarding_state: :travel_plan) }
      it { is_expected.to redirect_to new_travel_plan_path }
    end

    context "when I have already done this survey page" do
      before { account.update!(onboarding_state: :owner_balances) }
      it { is_expected.to redirect_to survey_person_balances_path(account.owner) }
    end

    context "when I have completed the entire survey" do
      before { account.update!(onboarding_state: :complete) }
      it { is_expected.to redirect_to root_path }
    end

    context "when I am on this survey page" do
      before { account.update!(onboarding_state: :account_type) }
      it { is_expected.to have_http_status(200) }
    end
  end
end
