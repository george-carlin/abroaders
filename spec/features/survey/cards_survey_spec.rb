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

    @account = create(:account)
    acc = account # anti-long-line pedanty
    @main_passenger = create(
      :main_passenger_with_spending, account: acc, first_name: "Steve"
    )
    if has_companion
      if main_passenger_has_added_cards
        @main_passenger.update_attributes!(has_added_cards: true)
      end
      @companion = create(
        :companion_with_spending, account: acc, first_name: "Pete"
      )
    end
    @account.reload

    login_as @account, scope: :account
  end
  after { @account.destroy }

  let(:account) { @account }

  let(:companion_page) { false }
  let(:has_companion) { false }
  let(:submit_form) { click_button "Save" }

  H = "h3"

  def bank_div_selector(bank)
    "##{bank}_cards"
  end

  def bank_bp_div_selector(bank, bp)
    "##{bank}_#{bp}_cards"
  end

  def card_checkbox(card)
    :"card_account_card_ids_#{card.id}"
  end


  shared_examples "card accounts survey" do
    it "lists cards grouped by bank, then B/P" do
      is_expected.to have_selector H, text: "Chase Personal Cards"
      is_expected.to have_selector bank_div_selector(:chase)
      is_expected.to have_selector bank_bp_div_selector(:chase, :personal)

      is_expected.to have_selector H, text: "Chase Business Cards"
      is_expected.to have_selector bank_div_selector(:chase)
      is_expected.to have_selector bank_bp_div_selector(:chase, :business)

      is_expected.to have_selector H, text: "Citibank Personal Cards"
      is_expected.to have_selector bank_div_selector(:citibank)
      is_expected.to have_selector \
                                  bank_bp_div_selector(:citibank, :personal)

      is_expected.to have_selector H, text: "Citibank Business Cards"
      is_expected.to have_selector bank_div_selector(:citibank)
      is_expected.to have_selector bank_bp_div_selector(:citibank, :business)

      is_expected.to have_selector H, text: "Barclays Personal Cards"
      is_expected.to have_selector bank_div_selector(:barclays)
      is_expected.to have_selector bank_bp_div_selector(:barclays, :personal)

      is_expected.to have_selector H, text: "Barclays Business Cards"
      is_expected.to have_selector bank_div_selector(:barclays)
      is_expected.to have_selector bank_bp_div_selector(:barclays, :business)
    end

    it "has a checkbox for each card" do
      @cards.each do |card|
        is_expected.to have_field card_checkbox(card)
      end
    end
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

  shared_examples "saves survey completion" do |opts={}|
    passenger = opts[:companion] ? "companion" : "main passenger"
    it "saves that the #{passenger} has added his/her cards" do
      passenger = opts[:companion] ? @companion : @main_passenger
      expect(passenger.has_added_cards?).to be_falsey # Sanity check
      submit_form
      expect(passenger.reload.has_added_cards?).to be_truthy
    end
  end

  describe "the 'main passenger' cards survey" do
    before { visit survey_card_accounts_path(:main) }

    context "when I do not have a travel companion on my account" do
      let(:has_companion) { false }

      it "asks me for “your” cards" do
        is_expected.to have_selector "h1", "Your Cards"
        is_expected.to have_content "recommend you a credit card"
        is_expected.to have_content "which cards you already have"
        is_expected.to have_content "you have been the primary cardholder"
      end

      describe "submitting the form" do
        before { submit_form }
        it "takes me to the balances survey page" do
          expect(current_path).to eq survey_balances_path
        end
      end
    end

    context "when I have a travel companion on my account" do
      let(:has_companion) { true }
      let(:main_passenger_has_added_cards) { false }

      it "asks me for “Name's” cards" do
        is_expected.to have_selector "h1", "Steve's Cards"
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
    end

    include_examples "card accounts survey"

    describe "selecting some cards" do
      before { select_cards }

      describe "and clicking 'Save'" do
        it "assigns the cards to the main passenger" do
          expect_to_assign_cards_to(@main_passenger)
        end

        include_examples "saves survey completion"
      end
    end # selecting some cards

    describe "submitting the form without selecting any cards" do
      it "doesn't assign any cards to any account" do
        expect { submit_form }.not_to change{CardAccount.count}
      end

      include_examples "saves survey completion"
    end
  end


  describe "the 'companion' cards survey" do
    let(:has_companion) { true }
    let(:main_passenger_has_added_cards) { true }

    before { visit survey_card_accounts_path(:companion) }

    it "asks me for “Name's” cards" do
      is_expected.to have_selector "h1", "Pete's Cards"
      is_expected.to have_content "recommend Pete a credit card"
      is_expected.to have_content "which cards he/she already has"
      is_expected.to have_content "Pete has been the primary cardholder"
    end

    include_examples "card accounts survey"

    describe "selecting some cards" do
      before { select_cards }

      describe "and clicking 'Save'" do
        # it "assigns the cards to the companion" do
        #   expect_to_assign_cards_to(@companion)
        # end

        include_examples "saves survey completion", companion: true
      end
    end

    describe "submitting the form without selecting any cards" do
      it "doesn't assign any cards to any account" do
        expect { submit_form }.not_to change{CardAccount.count}
      end

      include_examples "saves survey completion", companion: true
    end
  end
end
