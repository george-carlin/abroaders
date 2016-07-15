require "rails_helper"

describe "as a user viewing my cards - survey cards section" do
  subject { page }

  include_context "logged in"

  let(:me) { account.owner }
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

  let(:survey_cards_section)           { "#card_accounts_from_survey" }
  let(:owner_survey_cards_section)     { "#owner_card_accounts_from_survey" }
  let(:companion_survey_cards_section) { "#companion_card_accounts_from_survey" }

  shared_context "I added cards in survey" do
    let(:extra_setup) do
      @open_account   = create(:open_survey_card_account, person: me, card: @cards[0])
      @closed_account = create(:closed_survey_card_account, person: me, card: @cards[1])
    end

    let(:open_account)   { CardAccountOnPage.new(@open_account, self) }
    let(:closed_account) { CardAccountOnPage.new(@closed_account, self) }
  end

  shared_examples "lists owner cards" do
    it "has a section for them" do
      is_expected.to have_survey_cards_header
      is_expected.to have_selector owner_survey_cards_section
    end

    it "lists them" do
      within owner_survey_cards_section do
        expect(open_account).to be_present
        expect(closed_account).to be_present
      end

      expect(open_account).to have_content "Card Name: #{@cards[0].name}"
      expect(open_account).to have_content "Bank: #{@cards[0].bank_name}"
      expect(open_account).to have_content "Open"
      expect(open_account).to have_content @open_account.opened_at.strftime("%b %Y")
      expect(open_account).to have_no_content "Closed"

      expect(closed_account).to have_content "Card Name: #{@cards[1].name}"
      expect(closed_account).to have_content "Bank: #{@cards[1].bank_name}"
      expect(closed_account).to have_content "Closed"
      expect(closed_account).to have_content @closed_account.opened_at.strftime("%b %Y")
      expect(closed_account).to have_content @closed_account.closed_at.strftime("%b %Y")
    end

    it "doesn't have apply/decline btns for them" do
      expect(open_account).to have_no_apply_btn
      expect(open_account).to have_no_decline_btn
      expect(closed_account).to have_no_apply_btn
      expect(closed_account).to have_no_decline_btn
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
      include_examples "lists owner cards"

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
      include_examples "lists owner cards"

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

      let(:open_account)   { CardAccountOnPage.new(@open_account, self) }
      let(:closed_account) { CardAccountOnPage.new(@closed_account, self) }

      it "has a section for them" do
        is_expected.to have_survey_cards_header
        is_expected.to have_selector survey_cards_section
      end

      it "lists them" do
        within companion_survey_cards_section do
          expect(open_account).to be_present
          expect(closed_account).to be_present
        end

        expect(open_account).to have_content "Card Name: #{@cards[0].name}"
        expect(open_account).to have_content "Bank: #{@cards[0].bank_name}"
        expect(open_account).to have_content "Open"
        expect(open_account).to have_content @open_account.opened_at.strftime("%b %Y")
        expect(open_account).to have_no_content "Closed"

        expect(closed_account).to have_content "Card Name: #{@cards[1].name}"
        expect(closed_account).to have_content "Bank: #{@cards[1].bank_name}"
        expect(closed_account).to have_content "Closed"
        expect(closed_account).to have_content @closed_account.opened_at.strftime("%b %Y")
        expect(closed_account).to have_content @closed_account.closed_at.strftime("%b %Y")
      end

      it "doesn't have apply/decline btns for them" do
        expect(open_account).to have_no_apply_btn
        expect(open_account).to have_no_decline_btn
        expect(closed_account).to have_no_apply_btn
        expect(closed_account).to have_no_decline_btn
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

      let(:m_open)   { CardAccountOnPage.new(@m_open,   self) }
      let(:m_closed) { CardAccountOnPage.new(@m_closed, self) }
      let(:p_open)   { CardAccountOnPage.new(@p_open,   self) }
      let(:p_closed) { CardAccountOnPage.new(@p_closed, self) }

      it "lists them all" do
        within owner_survey_cards_section do
          expect(m_open).to be_present
          expect(m_closed).to be_present
        end

        within companion_survey_cards_section do
          expect(p_open).to be_present
          expect(p_closed).to be_present
        end

        [m_open, p_open].each do |account|
          expect(account).to have_content "Card Name: #{@cards[0].name}"
          expect(account).to have_content "Bank: #{@cards[0].bank_name}"
          expect(account).to have_content "Open"
          expect(account).to have_content account.model.opened_at.strftime("%b %Y")
          expect(account).to have_no_content "Closed"
        end

        [m_closed, p_closed].each do |account|
          expect(account).to have_content "Card Name: #{@cards[1].name}"
          expect(account).to have_content "Bank: #{@cards[1].bank_name}"
          expect(account).to have_content "Closed"
          expect(account).to have_content account.model.opened_at.strftime("%b %Y")
          expect(account).to have_content account.model.closed_at.strftime("%b %Y")
        end
      end
    end
  end
end
