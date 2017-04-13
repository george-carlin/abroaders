require "rails_helper"

RSpec.describe BalancesController do
  describe "GET #survey" do
    let(:account) { create(:account, :eligible) }
    let(:owner)   { account.owner }
    let(:person)  { owner }
    before { sign_in account }

    subject { get :survey, params: { person_id: person.id } }

    context "when I haven't reached this survey page yet" do
      before { account.update_attributes!(onboarding_state: :eligibility) }
      it { is_expected.to redirect_to survey_eligibility_path }
    end

    context "when onboarding state = 'owner balances'" do
      before { account.update_attributes!(onboarding_state: :owner_balances) }
      context "and person is owner" do
        it { is_expected.to have_http_status(200) }
      end

      context "and person is companion" do
        let(:person) { account.create_companion!(first_name: "X") }
        it { is_expected.to redirect_to survey_person_balances_path(owner) }
      end
    end

    context "when onboarding state = 'companion balances'" do
      before { account.update_attributes!(onboarding_state: :companion_balances) }
      context "and person is owner" do
        let!(:companion) { account.create_companion!(first_name: "X") }
        it { is_expected.to redirect_to survey_person_balances_path(companion) }
      end

      context "and person is companion" do
        let(:person) { account.create_companion!(first_name: "X") }
        it { is_expected.to have_http_status(200) }
      end
    end

    context "when I have completed this survey page" do
      before { account.update_attributes!(onboarding_state: :readiness) }
      it { is_expected.to redirect_to survey_readiness_path }
    end

    context "when I have completed the entire survey" do
      before { account.update_attributes!(onboarding_state: :complete) }
      it { is_expected.to redirect_to root_path }
    end
  end
end
