require "rails_helper"

describe "as a new user" do
  subject { page }
  before do
    @cards = [
      @chase_b    = create(:card, :business, bank: :chase),
      @chase_p    = create(:card, :personal, bank: :chase),
      @citibank_b = create(:card, :business, bank: :citibank),
      @citibank_p = create(:card, :personal, bank: :citibank),
      @barclays_b = create(:card, :business, bank: :barclays),
      @barclays_p = create(:card, :personal, bank: :barclays)
    ]

    @account = create(
      :account,
      onboarding_stage: if has_companion && main_passenger_has_added_cards
                          "companion_cards"
                        else
                          "main_passenger_cards"
                        end
    )
    @main_passenger = create(
      :main_passenger_with_spending,
      account: @account,
      first_name: "Steve"
    )
    if has_companion
      @companion = create(
        :companion_with_spending, account: @account, first_name: "Pete"
      )
    end
    @account.reload

    login_as(@account)
  end
  let(:account) { @account }

  let(:has_companion) { false }
  let(:submit_form) { click_button "Save" }

  def bank_div_selector(bank)
    "##{bank}_cards"
  end

  def bank_bp_div_selector(bank, bp)
    "##{bank}_#{bp}_cards"
  end

  def card_checkbox(card)
    :"card_account_card_ids_#{card.id}"
  end

  def select_cards
    check card_checkbox(@chase_b)
    check card_checkbox(@citibank_b)
    check card_checkbox(@citibank_p)
  end

  def expect_to_assign_cards_to(passenger)
    expect { submit_form }.to \
        change{passenger.card_accounts.unknown.count}.by(3)
    expect(passenger.card_accounts.map(&:card)).to match_array [
      @chase_b, @citibank_p, @citibank_b
    ]
  end

  shared_examples "card accounts survey" do
    it "lists cards grouped by bank, then B/P" do
      %w[chase citibank barclays].each do |bank|
        %w[personal business].each do |type|
          header = "#{bank.capitalize} #{type.capitalize} Cards"
          is_expected.to have_selector "h3", text: header
          is_expected.to have_selector bank_div_selector(bank)
          is_expected.to have_selector bank_bp_div_selector(bank, type)
        end
      end
    end

    it "has a checkbox for each card" do
      @cards.each { |card| is_expected.to have_field card_checkbox(card) }
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
        expect(account.reload.onboarding_stage).to eq "main_passenger_balances"
      end
    end

    context "when I have a travel companion on my account" do
      let(:has_companion) { true }
      let(:main_passenger_has_added_cards) { false }

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
        expect(account.reload.onboarding_stage).to eq "companion_cards"
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
    let(:main_passenger_has_added_cards) { true }

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
          expect(account.reload.onboarding_stage).to eq \
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
