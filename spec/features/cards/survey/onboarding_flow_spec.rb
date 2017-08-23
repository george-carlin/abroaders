require 'rails_helper'

RSpec.describe 'cards survey - onboarding flow', :js do
  let(:account) { create_account(:eligible) }

  let!(:products) { Array.new(2) { create(:card_product) } }

  let(:owner) { account.owner }
  let(:init_state) { 'owner_cards' }

  before do
    login_as_account(account)
    account.update!(onboarding_state: init_state, aw_in_survey: aw)
    account.create_companion!(first_name: 'X', eligible: c_el) if couples?
    account.reload
    visit survey_person_cards_path(person)
    click_button "Yes"
    click_button 'Save and continue'
  end

  let(:o_el) { true }
  let(:couples?) { false }

  describe 'solo account' do
    let(:person) { owner }

    context 'has AW' do
      let(:aw) { true }
      it { expect(account.reload.onboarding_state).to eq 'spending' }
      it { expect(current_path).to eq survey_spending_info_path }
    end

    context 'no AW' do
      let(:aw) { false }
      it { expect(account.reload.onboarding_state).to eq 'owner_balances' }
      it { expect(current_path).to eq survey_person_balances_path(owner) }
    end
  end

  context 'couples account' do
    let(:couples?) { true }
    let(:companion) { account.companion }

    context "owner's cards" do # if we're on this page then owner is always eligible
      let(:person) { owner }

      context 'companion eligible' do
        let(:c_el) { true }

        context 'has AW' do
          let(:aw) { true }
          it { expect(account.reload.onboarding_state).to eq 'companion_cards' }
          it { expect(current_path).to eq survey_person_cards_path(companion) }
        end

        context 'no AW' do
          let(:aw) { false }
          it { expect(account.reload.onboarding_state).to eq 'owner_balances' }
          it { expect(current_path).to eq survey_person_balances_path(owner) }
        end
      end

      context 'companion ineligible' do
        let(:c_el) { false }

        context 'has AW' do
          let(:aw) { true }
          it { expect(account.reload.onboarding_state).to eq 'spending' }
          it { expect(current_path).to eq survey_spending_info_path }
        end

        context 'no AW' do
          let(:aw) { false }
          it { expect(account.reload.onboarding_state).to eq 'owner_balances' }
          it { expect(current_path).to eq survey_person_balances_path(owner) }
        end
      end
    end

    context "companion's cards" do
      let(:person) { companion }
      let(:init_state) { 'companion_cards' }

      # companion must be eligible
      let(:c_el) { true }

      before { owner.update!(eligible: o_el) }

      context 'owner eligible' do
        let(:o_el) { true }

        context 'has AW' do
          let(:aw) { true }
          it { expect(account.reload.onboarding_state).to eq 'spending' }
          it { expect(current_path).to eq survey_spending_info_path }
        end

        context 'no AW' do
          let(:aw) { false }
          it { expect(account.reload.onboarding_state).to eq 'companion_balances' }
          it { expect(current_path).to eq survey_person_balances_path(companion) }
        end
      end

      context 'owner ineligible' do
        let(:c_el) { false }

        context 'has AW' do
          let(:aw) { true }
          it { expect(account.reload.onboarding_state).to eq 'spending' }
          it { expect(current_path).to eq survey_spending_info_path }
        end

        context 'no AW' do
          let(:aw) { false }
          it { expect(account.reload.onboarding_state).to eq 'companion_balances' }
          it { expect(current_path).to eq survey_person_balances_path(companion) }
        end
      end
    end
  end
end
