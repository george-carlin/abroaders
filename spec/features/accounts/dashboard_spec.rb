require "rails_helper"

describe "account dashboard" do
  include ModalMacros
  include ActionView::Helpers::UrlHelper

  let(:email) { "thedude@lebowski.com" }

  before { login_as_account(account.reload) }

  let(:visit_path) { visit root_path }

  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  subject { page }

  shared_examples "showing dashboard for eligible" do
    example "initial layout" do
      is_expected.to have_content t("dashboard.account.eligible.title")
      is_expected.to have_content "1. Complete profile"
      is_expected.to have_content "2. Tell us when you're ready"
      is_expected.to have_content "3. Apply for card"
      is_expected.to have_content "4. Earn bonus points"
      is_expected.to have_content "5. Book travel"
      is_expected.to have_link "let us know", href: edit_readiness_path
      is_expected.to have_link "travel plans", href: new_travel_plan_path
    end
  end

  shared_examples "showing dashboard for ineligible" do
    example "initial layout" do
      is_expected.to have_content t("dashboard.account.ineligible.message")
      is_expected.to have_content "1. Complete profile"
      is_expected.to have_content "2. Earn point"
      is_expected.to have_content "3. Travel"
    end
  end

  shared_examples "showing dashboard for ready" do
    example "initial layout" do
      is_expected.to have_content t("dashboard.account.ready.message")
      is_expected.to have_content "1. Complete profile"
      is_expected.to have_content "2. Wait 24-48 hours"
      is_expected.to have_content "3. Apply for card"
      is_expected.to have_content "4. Earn bonus points"
      is_expected.to have_content "5. Book travel"
    end
  end

  context "when account without companion" do
    let(:account) { create(:account, :onboarded, email: email) }

    context "and owner is eligible" do
      before do
        owner.update!(eligible: true)
        visit_path
      end

      include_examples "showing dashboard for eligible"
    end

    context "and owner is ineligible" do
      before do
        owner.update!(eligible: false)
        visit_path
      end

      include_examples "showing dashboard for ineligible"
    end

    context "and owner is ready" do
      before do
        owner.update!(ready: true)
        visit_path
      end

      include_examples "showing dashboard for ready"
    end
  end

  context "when account with companion" do
    let(:account) { create(:account, :with_companion, :onboarded, email: email) }

    context "and both people are ineligible" do
      before do
        owner.update!(eligible: false)
        companion.update!(eligible: false)
        visit_path
      end

      include_examples "showing dashboard for ineligible"
    end

    context "and at least one person is ready" do
      before do
        owner.update!(ready: true)
        visit_path
      end

      include_examples "showing dashboard for ready"
    end

    context "and either is ready, but at least one person is eligible" do
      before do
        owner.update!(ready: false)
        companion.update!(ready: false)
        owner.update!(eligible: true)
        visit_path
      end

      include_examples "showing dashboard for eligible"
    end
  end

  context "when account has at least one card recommendation" do
    let(:account) { create(:account, :with_companion, :onboarded, email: email) }
    let(:offer) { create(:offer) }
    before { owner.update!(last_recommendations_at: Time.now) }

    specify "account owner appears on the LHS of the page" do
      # unresolved_rec:
      create(:card_recommendation, person: owner, offer: offer)
      visit_path
      # owner selector goes before companion selector:
      expect(page).to have_selector "##{dom_id(owner)} + ##{dom_id(companion)}"
    end

    example "'unresolved cards' modal", :js do
      # unresolved_rec:
      create(:card_recommendation, person: owner, offer: offer)
      # resolved_rec:
      create(:card_recommendation, :applied, :open, person: owner, offer: offer)

      visit_path

      expect(page).to have_modal

      within_modal do
        expect(page).to have_content "You have 1 card recommendation which requires action"
        expect(page).to have_link "Continue", href: card_accounts_path
      end
    end

    example "no 'unresolved cards' modal", :js do
      offer = create(:offer)
      # resolved_rec:
      create(:card_recommendation, :applied, :open, person: owner, offer: offer)
      # CA from onboarding survey:
      create(:survey_card_account, person: owner)

      visit_path

      expect(page).to have_no_modal
      expect(page).to have_no_link "Continue", href: card_accounts_path
    end

    example "visit dashboard with recently accepted recommendation" do
      person = account.people.first
      person.update_attributes(last_recommendations_at: Time.current)
      create(:spending_info, person: person)

      visit_path

      expect(page).to have_no_content "#{person.first_name} is not ready to apply for cards."
    end
  end
end
