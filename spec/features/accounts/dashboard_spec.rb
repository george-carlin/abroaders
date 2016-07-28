require "rails_helper"

describe "account dashboard" do
  include ModalMacros

  let(:email) { "thedude@lebowski.com" }
  let(:account) { create(:account, email: email) }

  before { login_as_account(account.reload) }

  let(:visit_path) { visit root_path }

  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  specify "account owner appears on the LHS of the page" do
    create(:companion, account: account)
    visit_path
    # owner selector goes before companion selector:
    expect(page).to have_selector "##{dom_id(owner)} + ##{dom_id(companion)}"
  end

  example "'unresolved cards' modal", :js do
    offer = create(:offer)
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

end
