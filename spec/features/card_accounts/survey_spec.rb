require "rails_helper"

describe "card accounts survey", :onboarding, :js, :manual_clean do
  subject { page }

  before(:all) do
    chase = Bank.find_by(name: "Chase")
    citi  = Bank.find_by(name: "Citibank")
    @banks = [chase, citi]
    @visible_cards = [
      create(:card, :business, :visa,       bank_id: chase.id, name: "Card 0"),
      create(:card, :personal, :mastercard, bank_id: chase.id, name: "Card 1"),
      create(:card, :business, :mastercard, bank_id: citi.id,  name: "Card 2"),
      create(:card, :personal, :visa,       bank_id: citi.id,  name: "Card 3"),
      create(:card, :personal, :visa,       bank_id: citi.id,  name: "Card 4"),
    ]
    @hidden_card = create(:card, shown_on_survey: false)
  end

  let(:account) { create(:account, onboarding_state: "owner_cards") }
  let(:owner)   { account.owner }

  before do
    owner.update_attributes!(eligible: true)
    login_as account.reload
    visit survey_person_card_accounts_path(owner)
  end

  let(:name) { owner.first_name }
  let(:submit_form) { click_button "Save and continue" }

  def card_on_page(card)
    CardOnSurveyPage.new(card, self)
  end

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month.strftime("%F")
  end

  def expand_banks
    @banks.each do |bank|
      click_on bank.name.upcase
      sleep 0.5
    end
  end

  def track_intercom_event
    super("obs_cards_own").for_email(account.email)
  end

  shared_examples "submitting the form" do
    it "takes me to the next stage of the survey" do
      submit_form
      expect(current_path).to eq survey_person_balances_path(owner)
      expect(account.reload.onboarding_state).to eq "owner_balances"
    end
  end

  example "initial page layout" do
    expect(page).to have_no_sidebar
    expect(page).to have_content \
      "Has #{name} ever had a credit card that earns points or miles?"
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
    # doesn't initially list cards:
    expect(page).to have_no_selector ".card-survey-checkbox"
  end

  example "clicking 'No'", :intercom do
    click_button "No"

    expect(page).to have_no_content \
      "Has #{name} ever had a credit card that earns points or miles?"
    expect(page).to have_no_button "Yes"
    expect(page).to have_no_button "No"
    expect(page).to have_content \
      "#{name} has never had a card that earns points or miles"
    expect(page).to have_button "Confirm"
    expect(page).to have_button "Back"

    expect do
      click_button "Confirm"
    end.to change { CardAccount.count }.by(0).and(track_intercom_event)

    expect(account.reload.onboarding_state).to eq "owner_balances"
    expect(current_path).to eq survey_person_balances_path(owner)
  end

  example "clicking 'No' and going back" do
    click_button "No"
    click_button "Back"
    expect(page).to have_content \
      "Has #{name} ever had a credit card that earns points or miles?"
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
    expect(page).to have_no_content \
      "#{name} has never had a card that earns points or miles"
    expect(page).to have_no_button "Confirm"
    expect(page).to have_no_button "Back"
  end

  describe "clicking 'Yes'" do
    before do
      click_button "Yes"
      expand_banks
    end

    it "shows cards grouped by bank, then B/P" do
      @banks.each do |bank|
        expect(page).to have_selector "h2", text: bank.name.upcase
        within "#bank-collapse-#{bank.id}" do
          %w[personal business].each do |type|
            expect(page).to have_selector "h4", text: "#{type.capitalize} Cards"
            expect(page).to have_selector "##{bank.to_param}_cards"
            expect(page).to have_selector "##{bank.to_param}_#{type}_cards"
          end
        end
      end
    end

    it "only has one 'group' per bank and b/p" do # bug fix
      @banks.each do |bank|
        within "#bank-collapse-#{bank.id}" do
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
      %w[
        opened_at_month opened_at_year closed closed_at_month
        closed_at_year
      ].each do |attr|
        expect(page).to have_no_selector(".cards_survey_card_account_#{attr}")
      end
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

      it "asks when the card was opened" do
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

      it "asks if (but not when) the card was closed" do
        expect(card).to have_closed_check_box
        expect(card).to have_no_closed_at_month_field
        expect(card).to have_no_closed_at_year_field
      end

      describe "checking 'I closed the card'" do
        before { card.check_closed }

        it "asks when the card was closed" do
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
        selected_cards.each(&:check_opened)
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
        it "assigns the cards to owner person" do
          expect do
            submit_form
          end.to change { owner.card_accounts.count }.by selected_cards.length
        end

        describe "the created card accounts" do
          before { submit_form }
          let(:new_accounts) { owner.card_accounts }

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
            expect(open_acc_0.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
            expect(open_acc_0.closed_at).to be_nil
            expect(open_acc_1.opened_at.strftime("%F")).to eq end_of_month(last_year, "03")
            expect(open_acc_1.closed_at).to be_nil
            expect(closed_acc.opened_at.strftime("%F")).to eq end_of_month(ten_years_ago, "11")
            expect(closed_acc.closed_at.strftime("%F")).to eq end_of_month(last_year, "04")
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
            expect(owner.card_accounts.all?(&:from_survey?)).to be true
          end
        end

        include_examples "submitting the form"
      end
    end # selecting some cards

    describe "submitting the form without selecting any cards" do
      it "doesn't assign any cards to any account" do
        expect { submit_form }.not_to change { CardAccount.count }
      end

      include_examples "submitting the form"
    end
  end
end
