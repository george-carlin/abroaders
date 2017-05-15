require "rails_helper"

RSpec.describe TravelPlansController do
  describe "GET #new" do
    let(:account) { create_account }

    before { sign_in account }

    subject { get :new }

    context "when I haven't reached the travel plans onboarding page yet" do
      before { account.update_attributes!(onboarding_state: :home_airports) }
      it { is_expected.to redirect_to survey_home_airports_path }
    end

    context "when I have onboarded travel plans but not completed survey" do
      before { account.update_attributes!(onboarding_state: :account_type) }
      it { is_expected.to redirect_to type_account_path }
    end

    context "when I have completed the entire onboarding survey" do
      before { account.update_attributes!(onboarding_state: :complete) }
      it { is_expected.to have_http_status(200) }
    end

    context "when I am on onboarding my travel plans" do
      before { account.update_attributes!(onboarding_state: :travel_plan) }
      it { is_expected.to have_http_status(200) }
    end
  end
end
