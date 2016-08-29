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



  describe "POST #create" do
    let(:account) { create(:account, :onboarded_cards, :onboarded_balances) }

    before { sign_in account }

    describe "valid submission" do
      def post_create
        post :create, { params: { person_id: @person.id, person: { ready: true } } }
      end

      before do
        account.owner.update_attributes!(
          eligible:           true,
          onboarded_balances: true,
          onboarded_cards:    true,
        )
      end

      example "person is owner, account has no companion" do
        @person = account.owner
        expect(post_create).to redirect_to root_path
      end

      example "person is owner,  account has eligible companion" do
        @person = account.owner
        companion = create(:companion, account: account, eligible: true)
        expect(post_create).to redirect_to new_person_spending_info_path(companion)
      end

      example "person is owner, account has ineligible companion" do
        @person = account.owner
        companion = create(:companion, account: account, eligible: false)
        expect(post_create).to redirect_to survey_person_balances_path(companion)
      end

      example "person is companion" do
        # finish onboarding the owner so we don't get redirected to his survey pages:
        account.owner.update_attributes(ready: true)
        @person = create(
          :companion,
          :eligible,
          :onboarded_balances,
          :onboarded_cards,
          :onboarded_spending,
          account: account,
        )
        expect(post_create).to redirect_to root_path
      end
    end
  end
end
