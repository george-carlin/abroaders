require 'rails_helper'

RSpec.describe 'readiness survey page', :onboarding do
  let(:owner) { account.owner }
  let(:companion) { account.companion }

  context 'for a solo account' do
    let(:account) { create_account(:eligible, onboarding_state: 'readiness') }

    before do
      login_as_account(account)
      visit survey_readiness_path
    end

    example '' do
      expect(page).to have_field "Yes - I'm ready now", checked: true
      expect(page).to have_field "No - I'm not ready yet"
      expect(page).to have_no_content "#{owner.first_name} is ready"
    end

    example 'submitting "ready"' do
      click_button 'Save and continue'
      expect(owner.reload.unresolved_recommendation_request?).to be true
      expect(current_path).to eq new_phone_number_path
    end

    example 'submitting "ready"' do
      choose "No - I'm not ready yet"
      click_button 'Save and continue'
      expect(owner.reload.unresolved_recommendation_request?).to be false
      expect(current_path).to eq new_phone_number_path
    end
  end

  context 'for a couples account' do
    let(:account) { create_account(:couples, onboarding_state: 'readiness') }

    before do
      owner.update!(eligible: owner_eligible)
      companion.update!(eligible: companion_eligible)
      login_as_account(account)
      visit survey_readiness_path
    end

    let(:companion_eligible) { true }
    let(:companion_name) { companion.first_name }
    let(:owner_eligible) { true }
    let(:owner_name) { owner.first_name }

    context 'owner eligible' do
      let(:companion_eligible) { false }

      example '' do
        expect(page).to have_field "Yes - I'm ready now", checked: true
        expect(page).to have_field "No - I'm not ready yet"
        expect(page).to have_no_content "#{owner_name} is ready"
        expect(page).to have_no_content "#{companion_name} is ready"
      end

      example 'submitting "ready"' do
        click_button 'Save and continue'
        expect(owner.reload.unresolved_recommendation_request?).to be true
        expect(companion.reload.unresolved_recommendation_request?).to be false
        expect(current_path).to eq new_phone_number_path
      end

      example 'submitting "ready"' do
        choose "No - I'm not ready yet"
        click_button 'Save and continue'
        expect(owner.reload.unresolved_recommendation_request?).to be false
        expect(companion.reload.unresolved_recommendation_request?).to be false
        expect(current_path).to eq new_phone_number_path
      end
    end

    context 'when only companion is eligible' do
      let(:owner_eligible) { false }

      example '' do
        expect(page).to have_field "Yes - I'm ready now", checked: true
        expect(page).to have_field "No - I'm not ready yet"
        expect(page).to have_no_content "#{owner_name} is ready"
        expect(page).to have_no_content "#{companion_name} is ready"
      end

      example 'submitting "ready"' do
        click_button 'Save and continue'
        expect(owner.reload.unresolved_recommendation_request?).to be false
        expect(companion.reload.unresolved_recommendation_request?).to be true
        expect(current_path).to eq new_phone_number_path
      end

      example 'submitting "ready"' do
        choose "No - I'm not ready yet"
        click_button 'Save and continue'
        expect(owner.reload.unresolved_recommendation_request?).to be false
        expect(companion.reload.unresolved_recommendation_request?).to be false
        expect(current_path).to eq new_phone_number_path
      end
    end

    context 'both people are eligible' do
      example '' do
        expect(page).to have_field(
          "Both #{owner_name} and #{companion_name} are ready now", checked: true,
        )
        expect(page).to have_field("#{owner_name} is ready now but #{companion_name} isn't")
        expect(page).to have_field("#{companion_name} is ready now but #{owner_name} isn't")
        expect(page).to have_field('Neither of us is ready yet')
      end

      example 'both ready' do
        click_button 'Save and continue'
        expect(owner.reload.unresolved_recommendation_request?).to be true
        expect(companion.reload.unresolved_recommendation_request?).to be true
        expect(current_path).to eq new_phone_number_path
      end

      example 'owner ready' do
        choose "#{owner_name} is ready now but #{companion_name} isn't"
        click_button 'Save and continue'
        expect(owner.reload.unresolved_recommendation_request?).to be true
        expect(companion.reload.unresolved_recommendation_request?).to be false
        expect(current_path).to eq new_phone_number_path
      end

      example 'companion ready' do
        choose "#{companion_name} is ready now but #{owner_name} isn't"
        click_button 'Save and continue'
        expect(owner.reload.unresolved_recommendation_request?).to be false
        expect(companion.reload.unresolved_recommendation_request?).to be true
        expect(current_path).to eq new_phone_number_path
      end

      example 'neither ready' do
        choose 'Neither of us is ready yet'
        click_button 'Save and continue'
        expect(owner.reload.unresolved_recommendation_request?).to be false
        expect(companion.reload.unresolved_recommendation_request?).to be false
        expect(current_path).to eq new_phone_number_path
      end
    end
  end
end
