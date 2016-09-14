require "rails_helper"

describe CardAccountsController do
  include_context "account devise mapping"

  let(:account) { create(:account) }

  describe "GET #survey" do
    let(:account) do
      create(
        :account,
        onboarded_travel_plans:  onboarded_travel_plans,
        onboarded_type:          onboarded_type,
        onboarded_home_airports: onboarded_home_airports
      )
    end
    let(:person) { account.owner }

    subject do
      create(:spending_info, person: person) if onboarded_spending
      person.update_attributes!(
        onboarded_cards: onboarded_cards,
        eligible:        eligible,
      )
     
      sign_in account
      get :survey, params: { person_id: person.id }
    end

    context "when I haven't completed the home airports survey" do
      let(:onboarded_home_airports) { false }
      it { is_expected.to redirect_to survey_airports_path }
    end

    context "when I haven't completed the travel plans survey" do
      let(:onboarded_home_airports) { true }
      let(:onboarded_travel_plans) { false }
      it { is_expected.to redirect_to new_travel_plan_path }
    end

    let(:eligible)                { true }
    let(:onboarded_cards)         { false }
    let(:onboarded_spending)      { true }
    let(:onboarded_type)          { true }
    let(:onboarded_travel_plans)  { true }
    let(:onboarded_home_airports) { true }

    context "when I haven't chosen an account type yet" do
      let(:onboarded_type) { false }
      it { is_expected.to redirect_to type_account_path }
    end

    context "when I'm not eligible to apply for cards" do
      let(:eligible) { false }
      it { is_expected.to redirect_to survey_person_balances_path(person) }
    end

    context "when I need to complete the spending survey" do
      let(:onboarded_spending) { false }
      it { is_expected.to redirect_to new_person_spending_info_path(person) }
    end

    context "when I've already completed this survey" do
      let(:onboarded_cards) { true }
      it { is_expected.to redirect_to survey_person_balances_path(person) }
    end

  end
end
