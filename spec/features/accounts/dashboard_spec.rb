require 'rails_helper'

RSpec.describe 'account dashboard' do
  include ActionView::Helpers::UrlHelper

  let(:account) { create(:account, :onboarded) }

  before { login_as_account(account.reload) }

  let(:owner) { account.owner }

  subject { page }

  def it_has_steps_for_no_one_eligible
    visit root_path
    expect(page).to have_content t('dashboard.account.ineligible.message')
    expect(page).to have_content '1. Complete profile'
    expect(page).to have_content '2. Earn points'
    expect(page).to have_content '3. Travel'
  end

  def it_has_steps_for_eligible_no_rec_requests(person_type:)
    visit root_path
    request_path = new_recommendation_requests_path(person_type: person_type)
    expect(page).to have_content t('dashboard.account.eligible.title')
    expect(page).to have_content '1. Complete profile'
    expect(page).to have_content "2. Tell us when you're ready"
    expect(page).to have_content '3. Apply for card'
    expect(page).to have_content '4. Earn bonus points'
    expect(page).to have_content '5. Book travel'
    expect(page).to have_link 'let us know', href: request_path
    expect(page).to have_link 'travel plans', href: travel_plans_path
  end

  def it_has_steps_for_unresolved_rec_request
    visit root_path
    expect(page).to have_content t('dashboard.account.unresolved_rec_req.message')
    expect(page).to have_content '1. Complete profile'
    expect(page).to have_content '2. Wait 1-2 business days'
    expect(page).to have_content '3. Apply for card'
    expect(page).to have_content '4. Earn bonus points'
    expect(page).to have_content '5. Book travel'
  end

  context 'solo account' do
    example 'ineligible' do
      owner.update!(eligible: false)
      it_has_steps_for_no_one_eligible
    end

    example 'eligible, no rec request' do
      owner.update!(eligible: true)
      it_has_steps_for_eligible_no_rec_requests(person_type: 'owner')
    end

    example 'unresolved rec request' do
      owner.update!(eligible: true)
      create_rec_request('owner', account)
      it_has_steps_for_unresolved_rec_request
    end
  end

  context 'couples account' do
    let!(:companion) { account.create_companion!(first_name: 'Gabi') }

    example 'both people ineligible' do
      account.people.update_all(eligible: false)
      it_has_steps_for_no_one_eligible
    end

    example 'at least one eligible person, no rec requests' do
      owner.update!(eligible: true)
      it_has_steps_for_eligible_no_rec_requests(person_type: 'owner')
      companion.update!(eligible: true)
      it_has_steps_for_eligible_no_rec_requests(person_type: 'both')
      owner.update!(eligible: false)
      it_has_steps_for_eligible_no_rec_requests(person_type: 'companion')
    end

    example 'at least one unresolved rec request' do
      owner.update!(eligible: true)
      create_rec_request('owner', account)
      it_has_steps_for_unresolved_rec_request
    end
  end

  describe 'actionable recs modal' do
    let(:text) { 'You have card recommendations that require immediate action' }

    example 'when I have no recs that require action' do
      visit root_path
      expect(page).to have_no_content text
    end

    context 'when I have recs that require action' do
      before do
        create_card_recommendation(offer_id: create_offer.id, person_id: owner.id)
        run!(AdminArea::CardRecommendations::Complete, person_id: owner.id)
        visit root_path
      end

      it 'shows actionable recs modal' do
        expect(page).to have_content text
        expect(page).to have_link 'Continue', href: cards_path
      end

      example "and I've already clicked the link" do
        # it sets a cookie that prevents the modal from appearing for 24hrs
        click_link 'Continue'
        visit root_path
        expect(page).to have_no_content text
      end
    end
  end
end
