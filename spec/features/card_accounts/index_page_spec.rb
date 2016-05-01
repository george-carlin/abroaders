require "rails_helper"

describe "as a user viewing my cards" do
  include ActionView::Helpers::NumberHelper
  subject { page }

  include_context "logged in"

  let(:me) { account.main_passenger }
  let(:partner) { account.companion }

  before do
    @cards = create_list(:card, 5)
    extra_setup
    visit card_accounts_path
  end

  let(:extra_setup) { nil }

  def card_account_selector(account)
    "##{dom_id(account)}"
  end

  def have_survey_cards_header(have=true)
    send("have_#{"no_" unless have}selector", "h2", text: "Other Cards")
  end

  def survey_cards_section
    "#card_accounts_from_survey"
  end

  def have_apply_btn(rec, have=true)
    send("have_#{"no_"unless have}link", "Apply", href: apply_card_account_path(rec))
  end

  def have_no_apply_btn(rec)
    have_apply_btn(rec, false)
  end

  def decline_btn(recommendation)
    "#card_account_#{recommendation.id}_decline_btn"
  end

  def have_decline_btn(rec, have=true)
    send("have_#{"no_"unless have}selector", decline_btn(recommendation), text: "No Thanks")
  end

  def have_no_decline_btn(rec, have=true)
    have_decline_btn(rec, false)
  end

  context "when I didn't add any cards in the onboarding survey" do
    before { raise if me.card_accounts.from_survey.any? } # Sanity check

    it "doesn't have a section for them" do
      is_expected.to have_survey_cards_header(false)
      is_expected.to have_no_selector survey_cards_section
    end
  end

  context "when I added cards in the onboarding survey" do
    let(:extra_setup) do
      @open_account   = create(:card_account, :open, :survey, person: me, card: @cards[0])
      @closed_account = create(:card_account, :closed, :survey, person: me, card: @cards[1])
    end

    it "has a section for them" do
      is_expected.to have_selector "h2", "Other Cards"
      is_expected.to have_selector "#card_accounts_from_survey"
    end

    it "lists them" do
      within "#card_accounts_from_survey" do
        is_expected.to have_selector card_account_selector(@open_account)
        is_expected.to have_selector card_account_selector(@closed_account)
      end

      within card_account_selector(@open_account) do
        is_expected.to have_content "Card Name: #{@cards[0].name}"
        is_expected.to have_content "Bank: #{@cards[0].bank_name}"
        is_expected.to have_content "Open"
        is_expected.to have_content @open_account.opened_at.strftime("%b %Y")
        is_expected.not_to have_content "Closed"
      end

      within card_account_selector(@closed_account) do
        is_expected.to have_content "Card Name: #{@cards[1].name}"
        is_expected.to have_content "Bank: #{@cards[1].bank_name}"
        is_expected.to have_content "Closed"
        is_expected.to have_content @closed_account.opened_at.strftime("%b %Y")
        is_expected.to have_content @closed_account.closed_at.strftime("%b %Y")
      end
    end

    it "doesn't have apply/decline btns for them" do
      is_expected.to have_no_apply_btn(@open_account)
      is_expected.to have_no_decline_btn(@open_account)
      is_expected.to have_no_apply_btn(@closed_account)
      is_expected.to have_no_decline_btn(@closed_account)
    end
  end

  context "when I have a companion" do
    pending
  end

end
