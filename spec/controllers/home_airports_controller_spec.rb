require "rails_helper"

RSpec.describe HomeAirportsController do
  describe "GET #survey" do
    let(:account) { create_account }
    before { sign_in account }

    subject { get :survey }

    context "when I'm a new signup" do
      before { account.update_attributes!(onboarding_state: :home_airports) }
      it { is_expected.to have_http_status(200) }
    end

    context "when I have completed the home airports survey" do
      before { account.update_attributes!(onboarding_state: :travel_plan) }
      it { is_expected.to redirect_to new_travel_plan_path }
    end
  end
end
