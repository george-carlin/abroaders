require "rails_helper"

describe BalancesController do

  describe "GET #survey" do
    let(:account) { create(:account) }
    let(:person)  { account.owner }

    subject do
      create(:spending_info, person: person) if onboarded_spending
      person.update_attributes!(
        onboarded_cards: onboarded_cards,
        eligible:        eligible,
      )
    end
     
    before { sign_in account }
    subject { get :survey, params: { person_id: person.id } }

    context "when user needs to complete the travel plans survey" do
      it { is_expected.to redirect_to new_travel_plan_path }
    end

    context "when user needs to choose an account type" do
      before { onboard_travel_plans! }
      it { is_expected.to redirect_to type_account_path }
    end

    context "when user has already added their balances" do
      before do
        onboard_travel_plans!
        onboard_account_type!
        person.update_attributes!(eligible: false)
        onboard_balances!
      end

      it { is_expected.to redirect_to root_path }
    end
  end

  def onboard_travel_plans!
    account.update_attributes!(onboarded_travel_plans: true)
  end

  def onboard_account_type!
    account.update_attributes!(onboarded_type: true)
  end

  def onboard_balances!
    person.update_attributes!(onboarded_balances: true)
  end

end
