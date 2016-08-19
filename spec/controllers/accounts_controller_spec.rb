require "rails_helper"

describe AccountsController do
  include_context "account devise mapping"

  describe "GET #type" do
    let(:account) do
      create(
        :account,
        onboarded_travel_plans: onb_travel_plans,
        onboarded_type:         onb_type,
      )
    end
    before { sign_in account }

    subject { get :type }

    let(:onb_travel_plans) { true }
    let(:onb_type)         { false }

    context "when I haven't completed the travel plan survey" do
      let(:onb_travel_plans) { false }
      it { is_expected.to redirect_to new_travel_plan_path }
    end

    context "when I have already chosen an account type" do
      let(:onb_type) { true }
      it { is_expected.to redirect_to survey_person_balances_path(account.owner) }
    end

    context "when I am at the right point in the survey" do
      it { is_expected.to have_http_status(200) }
    end
  end

end
