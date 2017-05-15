require 'rails_helper'

# rather than testing one specific page, this file tests the 'request a rec'
# link/button that (sometimes) appears at the top of every page
RSpec.describe 'requesting a recommendation', :js do
  let(:btn_text) { 'Request new card recommendations' }
  let(:confirmation_survey_text) { "You're requesting new card recommendations" }

  context 'for a solo account' do
    # monthly spending must be present or the page will crash:
    let(:account) { create_account(:eligible, :onboarded, monthly_spending_usd: 1) }
    let(:person)  { account.owner }

    before do
      create(:spending_info, person: person)
      login_as account
    end

    example 'no unresolved recs' do
      raise if person.unresolved_recommendation_request? # sanity check
      visit root_path
      expect(page).to have_link btn_text
      click_link btn_text
      expect(page).to have_content confirmation_survey_text
    end

    example 'ineligible' do
      person.update!(eligible: false)
      account.reload
      visit root_path
      expect(page).to have_no_link btn_text
    end
  end

  context 'for a couples account' do
    let(:account) { create_account(:couples, :eligible, :onboarded, monthly_spending_usd: 1) }
    let(:companion) { account.companion }
    let(:owner) { account.owner }

    before do
      create(:spending_info, person: companion)
      create(:spending_info, person: owner)
      login_as account.reload
    end

    context 'both people can request' do
      before do
        raise if account.unresolved_recommendation_requests? # sanity check
        visit root_path
      end

      # Note that for these specs I'm testing for the presence/absence of the
      # "Name's credit score" text as a proxy for testing whether the conf.
      # survey asks about the owner/companion or both of them.

      it 'has form to request for one or both people' do
        expect(page).to have_link btn_text
        expect(page).to have_no_select :person_type
        click_link btn_text
        expect(page).to have_no_link btn_text
        expect(page).to have_select(
          :person_type,
          options: [owner.first_name, companion.first_name, 'Both of us'],
        )
        click_button 'Cancel'
        expect(page).to have_link btn_text
        expect(page).to have_no_select :person_type
      end

      example 'requesting for owner' do
        click_link btn_text
        select owner.first_name, from: :person_type
        click_button 'Go'
        expect(page).to have_content confirmation_survey_text
        expect(page).to have_content "#{owner.first_name}'s credit score"
        expect(page).to have_no_content "#{companion.first_name}'s credit score"
      end

      example 'selecting companion' do
        click_link btn_text
        select companion.first_name, from: :person_type
        click_button 'Go'
        expect(page).to have_content confirmation_survey_text
        expect(page).to have_content "#{companion.first_name}'s credit score"
        expect(page).to have_no_content "#{owner.first_name}'s credit score"
      end

      example 'selecting both' do
        click_link btn_text
        select 'Both of us', from: :person_type
        click_button 'Go'
        expect(page).to have_content confirmation_survey_text
        expect(page).to have_content "#{companion.first_name}'s credit score"
        expect(page).to have_content "#{owner.first_name}'s credit score"
      end
    end

    let(:owner_btn) { "#{btn_text} for #{owner.first_name}" }

    example 'only one person eligible' do
      owner.update!(eligible: false)
      visit root_path
      expect(page).to have_link btn_text
      click_link btn_text
      expect(page).to have_content confirmation_survey_text
      expect(page).to have_content "#{companion.first_name}'s credit score"
      expect(page).to have_no_content "#{owner.first_name}'s credit score"
    end

    example 'no-one is eligible' do
      account.people.each { |p| p.update!(eligible: false) }
      visit root_path
      expect(page).to have_no_link btn_text
    end

    example 'someone person already has an unresolved request' do
      create_rec_request('owner', account)
      visit root_path
      expect(page).to have_no_link btn_text
    end

    example 'someone already has an unresolved recommendation' do
      create_rec(person: companion)
      visit root_path
      expect(page).to have_no_link btn_text
    end
  end
end
