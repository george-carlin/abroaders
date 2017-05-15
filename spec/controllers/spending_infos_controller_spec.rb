require 'rails_helper'

RSpec.describe SpendingInfosController do
  let(:account) { create_account(onboarding_state: 'complete') }
  let(:owner) { account.owner }
  let(:companion) { account.companion }
  before { sign_in account }

  describe 'GET #show' do
    subject { get :show }

    def owner_eligible!
      owner.update!(eligible: true)
      create(:spending_info, person: owner)
    end

    context 'solo account - ineligible' do
      it { is_expected.to redirect_to root_path }
    end

    context 'solo account - eligible' do
      before { owner_eligible! }
      it { is_expected.to have_http_status(200) }
    end

    context 'couples account' do
      before do
        account.create_companion!(first_name: 'X', eligible: c_el)
        create(:spending_info, person: companion) if c_el
      end

      context '- both ineligible' do
        let(:c_el) { false }
        it { is_expected.to redirect_to root_path }
      end

      context 'couples account - one eligible' do
        let(:c_el) { true }
        it { is_expected.to have_http_status(200) }
      end

      context 'couples account - both eligible' do
        let(:c_el) { true }
        before { owner_eligible! }
        it { is_expected.to have_http_status(200) }
      end
    end
  end

  describe 'GET #survey' do
    before { account.people.each { |p| p.update!(eligible: true) } }

    subject { get :survey }

    context "when I haven't reached this survey page yet" do
      before { account.update_attributes!(onboarding_state: :owner_balances) }
      it { is_expected.to redirect_to survey_person_balances_path(owner) }
    end

    context 'when I am on this survey page' do
      before { account.update_attributes!(onboarding_state: :spending) }
      it { is_expected.to have_http_status(200) }
    end

    context 'when I have completed this survey page' do
      before { account.update_attributes!(onboarding_state: :readiness) }
      it { is_expected.to redirect_to survey_readiness_path }
    end

    context 'when I have completed the entire survey' do
      before { account.update_attributes!(onboarding_state: :complete) }
      it { is_expected.to redirect_to root_path }
    end
  end
end
