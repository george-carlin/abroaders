require "rails_helper"

describe ReadinessController do
  describe "GET #show" do
    let(:account) { create(:account, :onboarded_cards, :onboarded_balances) }
    let(:person)  { account.owner }

    before { sign_in account }

    subject { get :show, params: { person_id: person.id } }

    context "when person is ineligible" do
      before { person.update_attributes!(eligible: false) }
      it { is_expected.to redirect_to root_path }
    end

    context "when person is already ready" do
      before { person.update_attributes!(eligible: true, ready: true) }
      it { is_expected.to redirect_to root_path }
    end
  end
end
