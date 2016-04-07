require "rails_helper"

describe "as a new user" do
  subject { page }

  # Setup
  before do
    chase = Bank.find_by(name: "Chase")
    citi  = Bank.find_by(name: "Citibank")
    @visible_cards = [
      create(:card, :business, :visa,       bank_id: chase.id, name: "Card 0"),
      create(:card, :personal, :mastercard, bank_id: chase.id, name: "Card 1"),
      create(:card, :business, :mastercard, bank_id: citi.id,  name: "Card 2"),
      create(:card, :personal, :visa,       bank_id: citi.id,  name: "Card 3"),
    ]
    @hidden_card = create(:card, shown_on_survey: false)

    onboarding_stage = \
      has_companion && mp_has_added_cards ? "companion_cards" : "main_passenger_cards"

    @account = create(:account, onboarding_stage: onboarding_stage)
    @main_passenger = \
      create(:main_passenger_with_spending, account: @account, first_name: "Steve")
    if has_companion
      @companion = \
        create(:companion_with_spending, account: @account, first_name: "Pete")
    end
    login_as @account.reload
  end

  # Helpers
  let(:submit_form) { click_button "Save" }

  def card_checkbox(card)
    :"card_account_card_ids_#{card.id}"
  end

  let(:selected_cards) { @visible_cards.values_at(0, 2, 3) }

  def select_cards
    selected_cards.each { |card| check card_checkbox(card) }
  end

  def expect_to_assign_cards_to(passenger)
    expect { submit_form }.to \
        change{passenger.card_accounts.unknown.count}.by selected_cards.length
    expect(passenger.card_accounts.map(&:card)).to match_array selected_cards
  end

  # Config
  let(:has_companion) { false }

  shared_examples "card accounts survey" do
    it "lists cards grouped by bank, then B/P" do
      %w[chase citibank].each do |bank|
        %w[personal business].each do |type|
          header = "#{bank.capitalize} #{type.capitalize} Cards"
          is_expected.to have_selector "h3", text: header
          is_expected.to have_selector "##{bank.to_param}_cards"
          is_expected.to have_selector "##{bank}_#{type}_cards"
        end
      end
    end

    it "has a checkbox for each card" do
      @visible_cards.each do |card|
        is_expected.to have_field card_checkbox(card)
      end
    end

    describe "a business card's displayed name" do
      it "follows the format 'card name, BUSINESS, network, annual fee'" do
        within "##{dom_id(@visible_cards[0])}" do
          expect(page).to have_content "Card 0 business Visa"
        end
        within "##{dom_id(@visible_cards[2])}" do
          expect(page).to have_content "Card 2 business MasterCard"
        end
      end
    end

    describe "a personal card's displayed name" do
      it "follows the format 'card name, network, annual fee'" do
        within "##{dom_id(@visible_cards[1])}" do
          expect(page).to have_content "Card 1 MasterCard"
        end
        within "##{dom_id(@visible_cards[3])}" do
          expect(page).to have_content "Card 3 Visa"
        end
      end
    end


    it "doesn't show cards which the admin has opted to hide" do
      expect(page).not_to have_field card_checkbox(@hidden_card)
    end
  end

  describe "the 'main passenger' cards survey" do
    before { visit survey_card_accounts_path(:main) }

    context "when I do not have a travel companion on my account" do
      let(:has_companion) { false }

      it "asks me for “your” cards" do
        is_expected.to have_selector "h1", text: "Your Cards"
        is_expected.to have_content "recommend you a credit card"
        is_expected.to have_content "which cards you already have"
        is_expected.to have_content "you have been the primary cardholder"
      end

      describe "submitting the form" do
        before { submit_form }
        it "takes me to the balances survey page" do
          expect(current_path).to eq survey_balances_path(:main)
        end
      end

      it "marks my 'onboarding stage' as 'main passenger balances'" do
        submit_form
        expect(@account.reload.onboarding_stage).to eq "main_passenger_balances"
      end
    end

    context "when I have a travel companion on my account" do
      let(:has_companion) { true }
      let(:mp_has_added_cards) { false }

      it "asks me for “Name's” cards" do
        is_expected.to have_selector "h1", text: "Steve's Cards"
        is_expected.to have_content "recommend Steve a credit card"
        is_expected.to have_content "which cards he/she already has"
        is_expected.to have_content "Steve has been the primary cardholder"
      end

      describe "submitting the form" do
        before { submit_form }
        it "takes me to the companion card survey page" do
          expect(current_path).to eq survey_card_accounts_path(:companion)
        end
      end

      it "marks my 'onboarding stage' as 'companion balances'" do
        submit_form
        expect(@account.reload.onboarding_stage).to eq "companion_cards"
      end
    end

    include_examples "card accounts survey"

    describe "selecting some cards" do
      before { select_cards }

      describe "and clicking 'Save'" do
        it "assigns the cards to the main passenger" do
          expect_to_assign_cards_to(@main_passenger)
        end
      end
    end # selecting some cards

    describe "submitting the form without selecting any cards" do
      it "doesn't assign any cards to any account" do
        expect { submit_form }.not_to change{CardAccount.count}
      end
    end
  end

  describe "the 'companion' cards survey" do
    let(:has_companion) { true }
    let(:mp_has_added_cards) { true }

    before { visit survey_card_accounts_path(:companion) }

    it "asks me for “Name's” cards" do
      is_expected.to have_selector "h1", text: "Pete's Cards"
      is_expected.to have_content "recommend Pete a credit card"
      is_expected.to have_content "which cards he/she already has"
      is_expected.to have_content "Pete has been the primary cardholder"
    end

    include_examples "card accounts survey"

    describe "selecting some cards" do
      before { select_cards }

      describe "and clicking 'Save'" do
        it "assigns the cards to the companion" do
          expect_to_assign_cards_to(@companion)
        end

        it "marks my 'onboarding stage' as 'main passenger balances'" do
          submit_form
          expect(@account.reload.onboarding_stage).to eq \
                                            "main_passenger_balances"
        end
      end
    end

    describe "submitting the form without selecting any cards" do
      it "doesn't assign any cards to any account" do
        expect { submit_form }.not_to change{CardAccount.count}
      end
    end
  end
end
