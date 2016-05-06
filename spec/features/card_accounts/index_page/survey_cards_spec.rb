require "rails_helper"

describe "as a user viewing my cards - survey cards section" do
  include ActionView::Helpers::NumberHelper
  include CardAccountsIndexPageMacros

  subject { page }

  include_context "logged in"

  let(:me) { account.main_passenger }
  let(:partner) { account.companion }

  before do
    create(:companion, account: account) if has_partner
    @cards = create_list(:card, 2)
    extra_setup
    visit card_accounts_path
  end

  let(:extra_setup) { nil }

  let(:have_survey_cards_header) { have_selector "h2", text: "Other Cards" }
  let(:have_no_survey_cards_header) { have_no_selector "h2", text: "Other Cards" }

  let(:survey_cards_section)         { "#card_accounts_from_survey" }
  let(:main_survey_cards_section)    { "#main_person_card_accounts_from_survey" }
  let(:partner_survey_cards_section) { "#partner_card_accounts_from_survey" }

  shared_context "I added cards in survey" do
    let(:extra_setup) do
      @open_account   = create(:open_survey_card_account, person: me, card: @cards[0])
      @closed_account = create(:closed_survey_card_account, person: me, card: @cards[1])
    end
  end

  shared_examples "lists main passenger cards" do
    it "has a section for them" do
      is_expected.to have_survey_cards_header
      is_expected.to have_selector main_survey_cards_section
    end

    it "lists them" do
      within main_survey_cards_section do
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

  context "when I have no partner" do
    let(:has_partner) { false }

    context "and I didn't add any cards in the onboarding survey" do
      before { raise if me.card_accounts.from_survey.any? } # Sanity check

      it "doesn't have an 'Other Cards' section'" do
        is_expected.to have_no_survey_cards_header
        is_expected.to have_no_selector survey_cards_section
        is_expected.to have_no_content "has no other cards"
      end
    end

    context "and I added cards in the onboarding survey" do
      include_context  "I added cards in survey"
      include_examples "lists main passenger cards"

      it "doesn't divide 'Other Cards' into main/partner sections" do
        is_expected.to have_no_selector "h2", text: "#{me.first_name}'s cards"
      end
    end
  end

  context "when I have a partner" do
    let(:has_partner) { true }

    context "and neither of us added any cards in the onboarding survey" do
      it "doesn't have an 'Other Cards' section" do
        is_expected.to have_no_survey_cards_header
        is_expected.to have_no_selector survey_cards_section
      end
    end

    context "and only I added cards in the onboarding survey" do
      include_context  "I added cards in survey"
      include_examples "lists main passenger cards"

      it "notes that my partner didn't add any cards" do
        is_expected.to have_selector "h3", text: "#{partner.first_name}'s Cards"
        is_expected.to have_content "#{partner.first_name} has no other cards"
      end
    end

    context "and only my partner added cards in the onboarding survey" do
      let(:extra_setup) do
        @open_account   = create(:open_survey_card_account, person: partner, card: @cards[0])
        @closed_account = create(:closed_survey_card_account, person: partner, card: @cards[1])
      end

      it "has a section for them" do
        is_expected.to have_selector "h2", "Other Cards"
        is_expected.to have_selector "#card_accounts_from_survey"
      end

      it "lists them" do
        within partner_survey_cards_section do
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

      it "notes that I didn't add any cards" do
        is_expected.to have_selector "h3", text: "#{me.first_name}'s Cards"
        is_expected.to have_content "#{me.first_name} has no other cards"
      end
    end

    context "and my partner and I both added cards" do
      let(:extra_setup) do
        @m_open   = create(:open_survey_card_account,   person: me, card: @cards[0])
        @m_closed = create(:closed_survey_card_account, person: me, card: @cards[1])
        @p_open   = create(:open_survey_card_account,   person: partner, card: @cards[0])
        @p_closed = create(:closed_survey_card_account, person: partner, card: @cards[1])
      end

      it "lists them all" do
        within main_survey_cards_section do
          is_expected.to have_selector card_account_selector(@m_open)
          is_expected.to have_selector card_account_selector(@m_closed)
        end

        within partner_survey_cards_section do
          is_expected.to have_selector card_account_selector(@p_open)
          is_expected.to have_selector card_account_selector(@p_closed)
        end

        [@m_open, @p_open].each do |account|
          within card_account_selector(account) do
            is_expected.to have_content "Card Name: #{@cards[0].name}"
            is_expected.to have_content "Bank: #{@cards[0].bank_name}"
            is_expected.to have_content "Open"
            is_expected.to have_content account.opened_at.strftime("%b %Y")
            is_expected.not_to have_content "Closed"
          end
        end

        [@m_closed, @p_closed].each do |account|
          within card_account_selector(account) do
            is_expected.to have_content "Card Name: #{@cards[1].name}"
            is_expected.to have_content "Bank: #{@cards[1].bank_name}"
            is_expected.to have_content "Closed"
            is_expected.to have_content account.opened_at.strftime("%b %Y")
            is_expected.to have_content account.closed_at.strftime("%b %Y")
          end
        end
      end
    end
  end
end
