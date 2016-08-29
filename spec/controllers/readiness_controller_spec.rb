require "rails_helper"

describe ReadinessController do
  describe "GET #show" do
    before { skip } # TODO
    let(:account) { create(:account, :onboarded_cards, :onboarded_balances) }
    let(:person)  { account.owner }

    before { sign_in account }

    subject { get :show, params: { person_id: person.id } }

    context "when person has not given their readiness yet" do
      it { is_expected.to redirect_to new_person_readiness_path(person) }
    end

    context "when person is already ready" do
      before { person.update_attributes!(ready: true) }
      it { is_expected.to redirect_to root_path }
    end
  end
end
