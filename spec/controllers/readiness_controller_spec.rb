require "rails_helper"

describe ReadinessController do
  let(:account) { create(:account) }
  let(:owner)   { account.owner }
  before { sign_in account }

  describe "GET #survey" do
    subject { get :survey }

    context "when I haven't reached this survey page yet" do
      before { account.update_attributes!(onboarding_state: :eligibility) }
      it { is_expected.to redirect_to survey_eligibility_path }
    end

    context "when I am on this survey page" do
      before { account.update_attributes!(onboarding_state: :readiness) }
      it { is_expected.to have_http_status(200) }
    end

    context "when I have completed the survey" do
      before { account.update_attributes!(onboarding_state: :complete) }
      it { is_expected.to redirect_to root_path }
    end
  end

  describe "GET #edit" do
    subject { get :edit }

    context 'for a solo account' do
      let(:account) { create(:account, :onboarded) }

      before { account.owner.update_attributes!(eligible: el, ready: r) }

      let(:r) { false }

      context 'when ineligible' do
        let(:el) { false }
        it { is_expected.to redirect_to root_path }
      end

      context 'when eligible' do
        let(:el) { true }
        context 'when ready' do
          let(:r) { true }
          it { is_expected.to redirect_to root_path }
        end

        context 'when unready' do
          it { is_expected.to have_http_status(200) }
        end
      end
    end

    context 'for a couples account' do
      let(:account) { create(:couples_account, :onboarded) }

      before do
        account.owner.update_attributes!(eligible: own_el, ready: own_r)
        account.companion.update_attributes!(eligible: com_el, ready: com_r)
      end

      let(:own_r) { false }
      let(:com_r) { false }

      context 'when both people are ineligible' do
        let(:own_el) { false }
        let(:com_el) { false }
        it { is_expected.to redirect_to root_path }
      end

      context 'when only owner is eligible' do
        let(:own_el) { true }
        let(:com_el) { false }

        context 'and is ready' do
          let(:own_r) { true }
          it { is_expected.to redirect_to root_path }
        end

        context 'and is unready' do
          it { is_expected.to have_http_status(200) }
        end
      end

      context 'when only companion is eligible' do
        let(:own_el) { false }
        let(:com_el) { true }

        context 'and is ready' do
          let(:com_r) { true }
          it { is_expected.to redirect_to root_path }
        end

        context 'and is unready' do
          it { is_expected.to have_http_status(200) }
        end
      end

      context 'when both people are eligible' do
        let(:own_el) { true }
        let(:com_el) { true }

        context 'and both are ready' do
          let(:own_r) { true }
          let(:com_r) { true }
          it { is_expected.to redirect_to root_path }
        end

        context 'and only owner is ready' do
          let(:own_r) { true }
          it { is_expected.to have_http_status(200) }
        end

        context 'and only companion is ready' do
          let(:com_r) { true }
          it { is_expected.to have_http_status(200) }
        end

        context 'and neither are ready' do
          it { is_expected.to have_http_status(200) }
        end
      end
    end
  end
end
