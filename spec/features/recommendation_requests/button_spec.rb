require 'rails_helper'

# rather than testing one specific page, this file tests the 'request a rec'
# button that (usually) appears at the top of every page
RSpec.describe 'requesting a recommendation', :js do
  BTN_TEXT = 'Request new card recommendations'.freeze
  CONFIRMATION_SURVEY_TEXT = "You're requesting new card recommendations".freeze

  context 'for a solo account' do
    # monthly spending must be present or the page will crash:
    let(:account) { create(:account, :eligible, :onboarded, monthly_spending_usd: 1) }
    let(:person)  { account.owner }

    before do
      create(:spending_info, person: person)
      login_as account
    end

    example 'no unresolved recs' do
      raise unless person.unresolved_recommendation_request.nil? # sanity check
      visit root_path
      expect(page).to have_link BTN_TEXT
      click_link BTN_TEXT
      expect(page).to have_content CONFIRMATION_SURVEY_TEXT
    end

    example 'ineligible' do
      person.update!(eligible: false)
      visit root_path
      expect(page).to have_no_link BTN_TEXT
    end
  end

  context 'for a couples account' do
    let(:account) { create(:account, :couples, :eligible, :onboarded, monthly_spending_usd: 1) }
    let(:companion) { account.companion }
    let(:owner) { account.owner }

    before do
      create(:spending_info, person: companion)
      create(:spending_info, person: owner)
      login_as account.reload
    end

    context 'both people can request' do
      before do
        raise unless account.unresolved_recommendation_requests.none? # sanity check
        visit root_path
      end

      it 'has form to request for one or both people' do
        expect(page).to have_button BTN_TEXT
        expect(page).to have_no_select :person_type
        click_button BTN_TEXT
        expect(page).to have_no_button BTN_TEXT
        expect(page).to have_select(
          :person_type,
          options: [owner.first_name, companion.first_name, 'Both of us'],
        )
        click_button 'Cancel'
        expect(page).to have_button BTN_TEXT
        expect(page).to have_no_select :person_type
      end

      example 'selecting owner' do
        click_button BTN_TEXT
        select owner.first_name, from: :person_type
        click_button 'Go'
        expect(page).to have_content CONFIRMATION_SURVEY_TEXT
        # TODO test asks about owner and not companion
      end

      example 'selecting companion' do
        click_button BTN_TEXT
        select companion.first_name, from: :person_type
        click_button 'Go'
        expect(page).to have_content CONFIRMATION_SURVEY_TEXT
        expect(page).to have_content "#{companion.first_name}'s credit score"
        expect(page).to have_no_content "#{owner.first_name}'s credit score"
      end

      example 'selecting both' do
        click_button BTN_TEXT
        select 'Both of us', from: :person_type
        click_button 'Go'
        expect(page).to have_content CONFIRMATION_SURVEY_TEXT
        expect(page).to have_content "#{companion.first_name}'s credit score"
        expect(page).to have_content "#{owner.first_name}'s credit score"
      end
    end

    let(:owner_btn) { "#{BTN_TEXT} for #{owner.first_name}" }
    let(:companion_btn) { "#{BTN_TEXT} for #{companion.first_name}" }

    example 'only one person eligible' do
      owner.update!(eligible: false)
      visit root_path
      expect(page).to have_link companion_btn
      click_link companion_btn
      expect(page).to have_content CONFIRMATION_SURVEY_TEXT
      expect(page).to have_content "#{companion.first_name}'s credit score"
      expect(page).to have_no_content "#{owner.first_name}'s credit score"
    end

    example 'one person already has an unresolved request' do
      create_rec_request('owner', account)
      visit root_path
      expect(page).to have_link companion_btn
      click_link companion_btn
      expect(page).to have_content CONFIRMATION_SURVEY_TEXT
      expect(page).to have_content "#{companion.first_name}'s credit score"
      expect(page).to have_no_content "#{owner.first_name}'s credit score"
    end

    example 'no-one is eligible' do
      owner.update!(eligible: false)
      companion.update!(eligible: false)
      visit root_path
      expect(page).to have_no_button companion_btn
      expect(page).to have_no_button owner_btn
      expect(page).to have_no_button BTN_TEXT
    end

    example 'everyone already has an unresolved request' do
      create_rec_request('both', account)
      owner.update!(eligible: false)
      visit root_path
      expect(page).to have_no_button companion_btn
      expect(page).to have_no_button owner_btn
      expect(page).to have_no_button BTN_TEXT
    end
  end
end
