require "rails_helper"

describe AirportsController do
  describe "GET #survey" do
    let(:account) { create(:account) }
    let(:person)  { account.owner }

    before { sign_in account }

    subject { get :new }

    context "when I have onboarded home airports but not completed survey" do
      before do
        account.update_attributes!(onboarded_home_airports: true)
      end
      it { is_expected.to redirect_to survey_home_airports_path }
    end

    context "when I have completed the entire onboarding survey" do
      before do
        account.update_attributes!(onboarded_home_airports: true, onboarded_travel_plans: true, onboarded_type: true)
        person.update_attributes!(eligible: false, onboarded_balances: true)
      end
      it { is_expected.to have_http_status(200) }
    end
  end
end
