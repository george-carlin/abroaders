require "rails_helper"

describe SpendingInfosController do
  describe "GET #new" do
    let(:account) do
      create(
        :account,
        onboarded_travel_plans:  onboarded_travel_plans,
        onboarded_type:          onboarded_type,
        onboarded_home_airports: onboarded_home_airports,
      )
    end

    let(:person) { account.owner }

    let(:onboarded_travel_plans)  { true }
    let(:onboarded_home_airports) { true }
    let(:onboarded_type)          { true }
    let(:already_added)           { false }
    let(:eligible)                { true }

    before do
      create(:spending_info, person: person) if already_added
      person.update_attributes!(eligible: eligible)
    end

    before  { sign_in account }
    subject { get :new, params: { person_id: person.id } }

    context "when I have already added spending info" do
      let(:already_added) { true }
      it { is_expected.to redirect_to survey_person_card_accounts_path(person) }
    end

    context "when I haven't chosen an account type yet" do
      let(:onboarded_type) { false }
      it { is_expected.to redirect_to type_account_path }
    end

    context "when I haven't completed the travel plans survey" do
      let(:onboarded_travel_plans) { false }
      it { is_expected.to redirect_to new_travel_plan_path }
    end

    context "when I haven't completed the home airports survey" do
      let(:onboarded_home_airports) { false }
      it { is_expected.to redirect_to survey_home_airports_path }
    end

    context "when I'm not eligible to apply" do
      let(:eligible) { false }
      it { is_expected.to redirect_to survey_person_balances_path(person) }
    end
  end
end
