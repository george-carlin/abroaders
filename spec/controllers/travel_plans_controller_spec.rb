require "rails_helper"

describe TravelPlansController do
  describe "GET #new" do
    let(:account) { create(:account) }
    let(:person)  { account.owner }

    before { sign_in account }

    subject { get :new }

    context "when I have onboarded travel plans but not completed survey" do
      before do
        account.update_attributes!(onboarded_home_airports: true, onboarded_travel_plans: true)
      end
      it { is_expected.to redirect_to type_account_path }
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
