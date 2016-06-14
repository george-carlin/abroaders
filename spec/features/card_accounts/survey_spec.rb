require "rails_helper"

describe "card accounts survey", :onboarding, :js do
  subject { page }

  let!(:account) do
    create(
      :account,
      :onboarded_travel_plans => onboarded_travel_plans,
      :onboarded_type         => onboarded_type,
    )
  end
  let!(:me) { account.people.first }

  before do
    create(:spending_info, person: me) if onboarded_spending
    me.update_attributes!(first_name: "George", onboarded_cards: onboarded_cards)
    eligible ?  me.eligible_to_apply! : me.ineligible_to_apply!
    chase = Bank.find_by(name: "Chase")
    citi  = Bank.find_by(name: "Citibank")
    @visible_cards = [
      create(:card, :business, :visa,       bank_id: chase.id, name: "Card 0"),
      create(:card, :personal, :mastercard, bank_id: chase.id, name: "Card 1"),
      create(:card, :business, :mastercard, bank_id: citi.id,  name: "Card 2"),
      create(:card, :personal, :visa,       bank_id: citi.id,  name: "Card 3"),
      create(:card, :personal, :visa,       bank_id: citi.id,  name: "Card 4"),
    ]
    @hidden_card = create(:card, shown_on_survey: false)

    login_as account.reload

    # Sanity checks:
    raise unless eligible == me.eligible_to_apply?
    raise unless onboarded_cards == me.onboarded_cards?
    raise unless onboarded_spending == me.onboarded_spending?
    visit survey_person_card_accounts_path(me)
  end

  let(:eligible)           { true }
  let(:onboarded_cards)    { false }
  let(:onboarded_spending) { true }
  let(:onboarded_type)     { true }
  let(:onboarded_travel_plans) { true }

  let(:submit_form) { click_button "Submit" }

  def card_on_page(card)
    CardOnSurveyPage.new(card, self)
  end

  shared_examples "submitting the form" do
    it "takes me to the balances survey" do
      submit_form
      expect(current_path).to eq survey_person_balances_path(me)
    end

    it "marks me as having completed the cards survey" do
      submit_form
      expect(me.reload.onboarded_cards?).to be true
    end
  end

  context "when I haven't completed the travel plans survey" do
    let(:onboarded_travel_plans) { false }
    it "redirects me to the travel plan survey" do
      expect(current_path).to eq new_travel_plan_path
    end
  end

  context "when I haven't chosen an account type yet" do
    let(:onboarded_type) { false }
    it "redirects me to the accounts type survey" do
      expect(current_path).to eq type_account_path
    end
  end

  context "when I'm not eligible to apply for cards" do
    let(:eligible) { false }
    it "redirects me to my balances survey" do
      expect(current_path).to eq survey_person_balances_path(me)
    end
  end

  context "when I need to complete the spending survey" do
    let(:onboarded_spending) { false }
    it "redirects me to the spending survey" do
      expect(current_path).to eq new_person_spending_info_path(me)
    end
  end

  context "when I've already completed this survey" do
    let(:onboarded_cards) { true }
    it "redirects to their balances survey" do
      expect(current_path).to eq survey_person_balances_path(me)
    end
  end

  it "doesn't show the sidebar" do
    is_expected.to have_no_selector "#menu"
  end

  it "asks if I have ever had any cards that earn points or miles" do
    expect(page).to have_content \
      "Has George ever had a credit card that earns points or miles?"
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
  end

  it "doesn't initially list cards" do
    expect(page).to have_no_selector ".card-survey-checkbox"
  end

  describe "clicking 'No'" do
    before { click_button "No" }

    it "asks to confirm" do
      expect(page).to have_no_content \
        "Has George ever had a credit card that earns points or miles?"
      expect(page).to have_no_button "Yes"
      expect(page).to have_no_button "No"
      expect(page).to have_content \
        "George has never had a card that earns points or miles"
      expect(page).to have_button "Confirm"
      expect(page).to have_button "Back"
    end

    describe "and clicking 'Confirm'" do
      let(:submit_form) { click_button "Confirm" }

      it "doesn't assign any cards to any account" do
        expect{submit_form}.not_to change{CardAccount.count}
      end

      include_examples "submitting the form"
    end

    describe "and clicking 'Back'" do
      before { click_button "Back" }

      it "goes back" do
        expect(page).to have_content \
          "Has George ever had a credit card that earns points or miles?"
        expect(page).to have_button "Yes"
        expect(page).to have_button "No"
        expect(page).to have_no_content \
          "George has never had a card that earns points or miles"
        expect(page).to have_no_button "Confirm"
        expect(page).to have_no_button "Back"
      end
    end
  end

  describe "clicking 'Yes'" do
    before { click_button "Yes" }

    it "shows cards grouped by bank, then B/P" do
      %w[chase citibank].each do |bank|
        %w[personal business].each do |type|
          header = "#{bank.capitalize} #{type.capitalize} Cards"
          is_expected.to have_selector "h2", text: header
          is_expected.to have_selector "##{bank.to_param}_cards"
          is_expected.to have_selector "##{bank}_#{type}_cards"
        end
      end
    end

    it "only has one 'group' per bank and b/p" do # bug fix
      %w[chase citibank].each do |bank|
        %w[personal business].each do |type|
          expect(all("[id='#{bank.to_param}_cards']").length).to eq 1
          expect(all("[id='#{bank.to_param}_personal_cards']").length).to eq 1
          expect(all("[id='#{bank.to_param}_business_cards']").length).to eq 1
        end
      end
    end

    it "has a checkbox for each card" do
      @visible_cards.each do |card|
        expect(card_on_page(card)).to have_opened_check_box
      end
    end

    it "initially has no inputs for opened/closed dates" do
      def test(s); is_expected.to have_no_selector(s); end
      test ".cards_survey_card_account_opened_at_month"
      test ".cards_survey_card_account_opened_at_year"
      test ".cards_survey_card_account_closed"
      test ".cards_survey_card_account_closed_at_month"
      test ".cards_survey_card_account_closed_at_year"
    end

    describe "a business card's displayed name" do
      it "follows the format 'card name, BUSINESS, network'" do
        within "##{dom_id(@visible_cards[0])}" do
          expect(page).to have_content "Card 0 business Visa"
        end
        within "##{dom_id(@visible_cards[2])}" do
          expect(page).to have_content "Card 2 business MasterCard"
        end
      end
    end

    describe "a personal card's displayed name" do
      it "follows the format 'card name, network'" do
        within "##{dom_id(@visible_cards[1])}" do
          expect(page).to have_content "Card 1 MasterCard"
        end
        within "##{dom_id(@visible_cards[3])}" do
          expect(page).to have_content "Card 3 Visa"
        end
      end
    end

    it "doesn't show cards which the admin has opted to hide" do
      expect(card_on_page(@hidden_card)).not_to be_present
    end

    describe "clicking on a card" do
      before { skip } # This is too much goddamn effort and I don't have time before launch
      let(:card) { @visible_cards[0] }
      let(:card_selector) { "##{dom_id(card)}" }

      let(:checkbox) { find(card_selector + " input[type=checkbox]") }

      before { raise if checkbox[:checked] } # sanity check

      describe "on the checkbox itself" do
        before { checkbox.click }
        it "checks the checkbox" do
          expect(checkbox.reload[:checked]).to be true
        end
      end

      describe "on the label" do
        before { find(card_selector + " label").click }
        it "checks the checkbox" do
          expect(checkbox.reload[:checked]).to be true
        end
      end

      describe "anywhere else in the card's box" do
        before { find(card_selector).click }
        it "checks the checkbox" do
          expect(checkbox.reload[:checked]).to be true
        end
      end
    end

    describe "selecting a card" do
      let(:card) { card_on_page(@visible_cards[0]) }

      before { card.check_opened }

      it "asks me when I opened the card" do
        expect(card).to have_opened_at_month_field
        expect(card).to have_opened_at_year_field
      end

      context "and unselecting it again" do
        before { card.uncheck_opened }

        it "hides the opened/closed inputs" do
          expect(card).to have_no_opened_at_month_field
          expect(card).to have_no_opened_at_year_field
          expect(card).to have_no_closed_check_box
          expect(card).to have_no_closed_at_month_field
          expect(card).to have_no_closed_at_year_field
        end
      end

      describe "the 'opened at' input" do
        it "has a date range from 10 years ago - this month"
      end

      it "asks me if (but not when) I closed the card" do
        expect(card).to have_closed_check_box
        expect(card).to have_no_closed_at_month_field
        expect(card).to have_no_closed_at_year_field
      end

      describe "checking 'I closed the card'" do
        before { card.check_closed }

        it "asks me when I closed it" do
          expect(card).to have_closed_check_box
          expect(card).to have_closed_at_month_field
          expect(card).to have_closed_at_year_field
        end

        describe "selecting an 'opened at' date" do
          it "hides earlier dates from the 'closed at' input" do
            skip
          end
        end

        describe "then unchecking it again" do
          before { card.uncheck_closed }

          it "hides the 'when did I close it'" do
            expect(card).to have_closed_check_box
            expect(card).to have_no_closed_at_month_field
            expect(card).to have_no_closed_at_year_field
          end

          describe "and submitting the form" do
            it "doesn't mark the card as closed"
          end
        end
      end
    end

    describe "selecting some cards" do
      let(:selected_cards) { @visible_cards.values_at(0, 2, 3).map { |c| card_on_page(c) } }
      let(:closed_card) { selected_cards.first }
      let(:open_cards)  { selected_cards.drop(1) }

      let(:this_year) { Date.today.year.to_s }
      let(:last_year) { (Date.today.year - 1).to_s }
      let(:ten_years_ago) { (Date.today.year - 10).to_s }

      before do
        selected_cards.each { |card| card.check_opened }
        select "Jan",     from: open_cards[0].opened_at_month
        select this_year, from: open_cards[0].opened_at_year
        select "Mar",     from: open_cards[1].opened_at_month
        select last_year, from: open_cards[1].opened_at_year
        select "Nov",     from: closed_card.opened_at_month
        select ten_years_ago, from: closed_card.opened_at_year
        closed_card.check_closed
        select "Apr",     from: closed_card.closed_at_month
        select last_year, from: closed_card.closed_at_year
      end

      describe "and submitting the form" do
        it "assigns the cards to me" do
          expect do
            submit_form
          end.to change{me.card_accounts.count}.by selected_cards.length
        end

        describe "the created card accounts" do
          before { submit_form }
          let(:new_accounts) { me.card_accounts }

          specify "have the right cards" do
            expect(new_accounts.map(&:card)).to match_array selected_cards.map(&:card)
          end

          specify "have no offers" do
            expect(new_accounts.map(&:offer).compact).to be_empty
          end

          specify "have the given opened and closed dates" do
            open_acc_0 = new_accounts.find_by(card_id: open_cards[0].id)
            open_acc_1 = new_accounts.find_by(card_id: open_cards[1].id)
            closed_acc = new_accounts.find_by(card_id: closed_card.id)
            expect(open_acc_0.opened_at.strftime("%F")).to eq "#{this_year}-01-01"
            expect(open_acc_0.closed_at).to be_nil
            expect(open_acc_1.opened_at.strftime("%F")).to eq "#{last_year}-03-01"
            expect(open_acc_1.closed_at).to be_nil
            expect(closed_acc.opened_at.strftime("%F")).to eq "#{ten_years_ago}-11-01"
            expect(closed_acc.closed_at.strftime("%F")).to eq "#{last_year}-04-01"
          end

          specify "have the right statuses" do
            open_acc_0 = new_accounts.find_by(card_id: open_cards[0].id)
            open_acc_1 = new_accounts.find_by(card_id: open_cards[1].id)
            closed_acc = new_accounts.find_by(card_id: closed_card.id)
            expect(open_acc_0.status).to eq "open"
            expect(open_acc_1.status).to eq "open"
            expect(closed_acc.status).to eq "closed"
          end

          specify "have 'from survey' as their source" do
            expect(me.card_accounts.all? { |ca| ca.from_survey? }).to be true
          end
        end

        include_examples "submitting the form"
      end
    end # selecting some cards

    describe "submitting the form without selecting any cards" do
      it "doesn't assign any cards to any account" do
        expect{submit_form}.not_to change{CardAccount.count}
      end

      include_examples "submitting the form"
    end
  end
end
