require 'rails_helper'

RSpec.describe 'award wallet survey page', :js do
  let(:account) { create_account }
  let(:owner) { account.owner }

  before do
    account.update!(onboarding_state: 'award_wallet')
    owner.update!(eligible: o_el)
    login_as_account(account)
    visit integrations_award_wallet_survey_path
  end

  let(:o_el) { true }

  let(:yes_btn) { 'Yes - I use AwardWallet' }
  let(:no_btn) { 'No - I don\'t use AwardWallet' }

  example 'page' do
    expect(page).to have_content 'Do You Use AwardWallet?'
    expect(page).to have_link yes_btn
    expect(page).to have_link no_btn
  end

  example 'confirmation' do
    click_link yes_btn
    expect(page).to have_no_link yes_btn
    expect(page).to have_no_link no_btn
    expect(page).to have_content 'You have an AwardWallet account'
    expect(page).to have_button 'Confirm'
    expect(page).to have_link 'Back'
    expect(page).to have_no_content 'You do\'nt have an AwardWallet account'

    click_link 'Back'
    expect(page).to have_link yes_btn
    expect(page).to have_link no_btn
    expect(page).to have_no_content 'You have an AwardWallet account'
    expect(page).to have_no_button 'Confirm'
    expect(page).to have_no_link 'Back'
    expect(page).to have_no_content "You don't have an AwardWallet account"

    click_link no_btn
    expect(page).to have_no_link yes_btn
    expect(page).to have_no_link no_btn
    expect(page).to have_no_content 'You have an AwardWallet account'
    expect(page).to have_button 'Confirm'
    expect(page).to have_link 'Back'
    expect(page).to have_content "You don't have an AwardWallet account"
  end

  def no!
    click_link no_btn
    click_button 'Confirm'
  end

  def yes!
    click_link yes_btn
    click_button 'Confirm'
  end

  example 'confirming "Yes"' do
    yes!
    expect(account.reload.aw_in_survey).to be true
  end

  example 'confirming "No"' do
    no!
    expect(account.reload.aw_in_survey).to be false
  end

  describe 'next survey page' do
    context 'solo account - eligible owner' do
      let(:o_el) { true }

      example 'yes' do
        yes!
        expect(account.reload.onboarding_state).to eq 'owner_cards'
      end

      example 'no' do
        no!
        expect(account.reload.onboarding_state).to eq 'owner_cards'
      end
    end

    context 'solo account - ineligible owner' do
      let(:o_el) { false }

      example 'yes' do
        yes!
        expect(account.reload.onboarding_state).to eq 'phone_number'
      end

      example 'no' do
        no!
        expect(account.reload.onboarding_state).to eq 'owner_balances'
      end
    end

    context 'couples account' do
      before do
        account.create_companion!(first_name: 'X', eligible: c_el)
        account.reload
      end

      context 'both eligible' do
        let(:o_el) { true }
        let(:c_el) { true }

        example 'yes' do
          yes!
          expect(account.reload.onboarding_state).to eq 'owner_cards'
        end

        example 'no' do
          no!
          expect(account.reload.onboarding_state).to eq 'owner_cards'
        end
      end

      context 'owner eligible' do
        let(:o_el) { true }
        let(:c_el) { false }

        example 'yes' do
          yes!
          expect(account.reload.onboarding_state).to eq 'owner_cards'
        end

        example 'no' do
          no!
          expect(account.reload.onboarding_state).to eq 'owner_cards'
        end
      end

      context 'comp eligible' do
        let(:o_el) { false }
        let(:c_el) { true }

        example 'yes' do
          yes!
          expect(account.reload.onboarding_state).to eq 'companion_cards'
        end

        example 'no' do
          no!
          expect(account.reload.onboarding_state).to eq 'owner_balances'
        end
      end

      context 'both ineligible' do
        let(:o_el) { false }
        let(:c_el) { false }

        example 'yes' do
          yes!
          expect(account.reload.onboarding_state).to eq 'phone_number'
        end

        example 'no' do
          no!
          expect(account.reload.onboarding_state).to eq 'owner_balances'
        end
      end
    end
  end
end
