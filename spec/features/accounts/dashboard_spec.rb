require "rails_helper"

RSpec.describe "account dashboard" do
  include ActionView::Helpers::UrlHelper

  let(:account) { create(:account, :onboarded) }

  before { login_as_account(account.reload) }

  let(:owner) { account.owner }

  subject { page }

  shared_examples "showing dashboard for eligible" do
    example "initial layout" do
      visit root_path
      is_expected.to have_content t("dashboard.account.eligible.title")
      is_expected.to have_content "1. Complete profile"
      is_expected.to have_content "2. Tell us when you're ready"
      is_expected.to have_content "3. Apply for card"
      is_expected.to have_content "4. Earn bonus points"
      is_expected.to have_content "5. Book travel"
      is_expected.to have_link "let us know", href: edit_readiness_path
      is_expected.to have_link "travel plans", href: travel_plans_path
    end
  end

  shared_examples "showing dashboard for ineligible" do
    example "initial layout" do
      visit root_path
      is_expected.to have_content t("dashboard.account.ineligible.message")
      is_expected.to have_content "1. Complete profile"
      is_expected.to have_content "2. Earn point"
      is_expected.to have_content "3. Travel"
    end
  end

  shared_examples "showing dashboard for ready" do
    example "initial layout" do
      visit root_path
      is_expected.to have_content t("dashboard.account.ready.message")
      is_expected.to have_content "1. Complete profile"
      is_expected.to have_content "2. Wait 24-48 hours"
      is_expected.to have_content "3. Apply for card"
      is_expected.to have_content "4. Earn bonus points"
      is_expected.to have_content "5. Book travel"
    end
  end

  context 'solo account' do
    context 'eligible' do
      before { owner.update!(eligible: true) }
      include_examples 'showing dashboard for eligible'
    end

    context 'ineligible' do
      before { owner.update!(eligible: false) }
      include_examples 'showing dashboard for ineligible'
    end

    context 'ready' do
      before { owner.update!(eligible: true, ready: true) }
      include_examples 'showing dashboard for ready'
    end
  end

  context 'couples account' do
    let(:companion) { account.create_companion!(first_name: 'Gabi') }

    context 'both people are ineligible' do
      before do
        owner.update!(eligible: false)
        companion.update!(eligible: false)
      end

      include_examples "showing dashboard for ineligible"
    end

    context 'at least one eligible person, neither ready' do
      before do
        owner.update!(ready: false)
        companion.update!(ready: false)
        owner.update!(eligible: true)
        visit root_path
      end

      include_examples "showing dashboard for eligible"
    end

    context 'at least one ready person' do
      before { owner.update!(ready: true) }
      include_examples "showing dashboard for ready"
    end
  end

  describe 'actionable recs modal' do
    let(:text) { 'You have card recommendations that require immediate action' }
    example "when I have no recs that require action" do
      visit root_path
      expect(page).to have_no_content text
    end

    context "when I have recs that require action" do
      before do
        create_card_recommendation(offer_id: create_offer.id, person_id: owner.id)
        run!(AdminArea::CardRecommendations::Operation::Complete, person_id: owner.id)
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
