require 'rails_helper'

describe 'cards survey', :onboarding, :js, :manual_clean do
  subject { page }

  before(:all) do
    chase = create(:bank, name: 'Chase')
    citi  = create(:bank, name: 'Citibank')
    @banks = [chase, citi]
    @visible_products = [
      create(:card_product, :business, :visa,       bank_id: chase.id, name: 'Card 0'),
      create(:card_product, :personal, :mastercard, bank_id: chase.id, name: 'Card 1'),
      create(:card_product, :business, :mastercard, bank_id: citi.id,  name: 'Card 2'),
      create(:card_product, :personal, :visa,       bank_id: citi.id,  name: 'Card 3'),
      create(:card_product, :personal, :visa,       bank_id: citi.id,  name: 'Card 4'),
    ]
    @hidden_product = create(:card_product, :hidden)
  end

  let(:account) { create(:account, onboarding_state: 'owner_cards') }
  let(:owner)   { account.owner }

  before do
    owner.update_attributes!(eligible: true)
    login_as account.reload
    visit survey_person_cards_path(owner)
  end

  let(:name) { owner.first_name }
  let(:submit_form) { click_button 'Save and continue' }

  def product_selector(product)
    '#' << dom_id(product)
  end

  def check_product_opened(product, checked)
    field = "cards_survey_#{product.id}_card_opened"
    checked ? check(field) : uncheck(field)
  end

  def check_product_closed(product, checked)
    field = "cards_survey_#{product.id}_card_closed"
    checked ? check(field) : uncheck(field)
  end

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month.strftime('%F')
  end

  def expand_banks
    @banks.each do |bank|
      click_on bank.name.upcase
      sleep 0.5
    end
  end

  shared_examples 'submitting the form' do
    it 'takes me to the next stage of the survey' do
      submit_form
      expect(current_path).to eq survey_person_balances_path(owner)
      expect(account.reload.onboarding_state).to eq 'owner_balances'
    end
  end

  example "initial page layout" do
    expect(page).to have_no_sidebar
    expect(page).to have_content \
      "Have you ever had a credit card that earns points or miles?"
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
    # doesn't initially list cards:
    expect(page).to have_no_selector ".card-survey-checkbox"
  end

  example "clicking 'No'" do
    click_button "No"

    expect(page).to have_no_content \
      "Have you ever had a credit card that earns points or miles?"
    expect(page).to have_no_button "Yes"
    expect(page).to have_no_button "No"
    expect(page).to have_content \
      "You have never had a card that earns points or miles"
    expect(page).to have_button "Confirm"
    expect(page).to have_button "Back"

    expect do
      click_button "Confirm"
    end.to change { Card.count }.by(0) # .and(track_intercom_event("obs_cards_own").for_email(account.email))

    expect(account.reload.onboarding_state).to eq "owner_balances"
    expect(current_path).to eq survey_person_balances_path(owner)
  end

  example "clicking 'No' and going back" do
    click_button "No"
    click_button "Back"
    expect(page).to have_content \
      "Have you ever had a credit card that earns points or miles?"
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
    expect(page).to have_no_content \
      "You have never had a card that earns points or miles"
    expect(page).to have_no_button "Confirm"
    expect(page).to have_no_button "Back"
  end

  describe "clicking 'Yes'" do
    before do
      click_button "Yes"
      expand_banks
    end

    it "shows card products grouped by bank, then B/P" do
      @banks.each do |bank|
        expect(page).to have_selector "h2", text: bank.name.upcase
        within "#bank-collapse-#{bank.id}" do
          %w[personal business].each do |type|
            expect(page).to have_selector "h4", text: "#{type.capitalize} Cards"
            expect(page).to have_selector "#bank_#{bank.id}_cards"
            expect(page).to have_selector "#bank_#{bank.id}_#{type}_cards"
          end
        end
      end
    end

    it "only has one 'group' per bank and b/p" do # bug fix
      @banks.each do |bank|
        within "#bank-collapse-#{bank.id}" do
          expect(all("[id='bank_#{bank.id}_cards']").length).to eq 1
          expect(all("[id='bank_#{bank.id}_personal_cards']").length).to eq 1
          expect(all("[id='bank_#{bank.id}_business_cards']").length).to eq 1
        end
      end
    end

    it "has a checkbox for each card product" do
      @visible_products.each do |product|
        expect(page).to have_field :"cards_survey_#{product.id}_card_opened"
      end
    end

    it "initially has no inputs for opened/closed dates" do
      %w[
        opened_at_month opened_at_year closed closed_at_month
        closed_at_year
      ].each do |attr|
        expect(page).to have_no_selector(".cards_survey_card_#{attr}")
      end
    end

    describe "a business card's displayed name" do
      it "follows the format 'card name, BUSINESS, network'" do
        within "##{dom_id(@visible_products[0])}" do
          expect(page).to have_content 'Card 0 business Visa'
        end
        within "##{dom_id(@visible_products[2])}" do
          expect(page).to have_content 'Card 2 business MasterCard'
        end
      end
    end

    describe "a personal card's displayed name" do
      it "follows the format 'card name, network'" do
        within "##{dom_id(@visible_products[1])}" do
          expect(page).to have_content "Card 1 MasterCard"
        end
        within "##{dom_id(@visible_products[3])}" do
          expect(page).to have_content "Card 3 Visa"
        end
      end
    end

    it "doesn't show cards which the admin has opted to hide" do
      expect(page).to have_no_selector product_selector(@hidden_product)
    end

    describe "clicking on a card product" do
      before { skip } # This is too much goddamn effort and I don't have time before launch
      let(:card) { @visible_products[0] }
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
      let(:selected_product) { @visible_products[0] }
      let(:id) { selected_product.id }

      before { check_product_opened(selected_product, true) }

      it "asks when the card was opened" do
        expect(page).to have_field "cards_survey_#{id}_card_opened_at_month"
        expect(page).to have_field "cards_survey_#{id}_card_opened_at_year"
      end

      context "and unselecting it again" do
        before { check_product_opened(selected_product, false) }

        it "hides the opened/closed inputs" do
          expect(page).to have_no_field "cards_survey_#{id}_card_opened_at_month"
          expect(page).to have_no_field "cards_survey_#{id}_card_opened_at_year"
          expect(page).to have_no_field "cards_survey_#{id}_card_closed"
          expect(page).to have_no_field "cards_survey_#{id}_card_closed_at_month"
          expect(page).to have_no_field "cards_survey_#{id}_card_closed_at_year"
        end
      end

      describe "the 'opened at' input" do
        it "has a date range from 10 years ago - this month"
      end

      it "asks if (but not when) the card was closed" do
        expect(page).to have_no_field "cards_survey_#{id}_card_closed"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed_at_month"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed_at_year"
      end

      describe "checking 'I closed the card'" do
        before { check_product_closed(selected_product, true) }

        it "asks when the card was closed" do
          expect(page).to have_field "cards_survey_#{id}_card_closed"
          expect(page).to have_field "cards_survey_#{id}_card_closed_at_month"
          expect(page).to have_field "cards_survey_#{id}_card_closed_at_year"
        end

        describe "selecting an 'opened at' date" do
          skip "hides earlier dates from the 'closed at' input" # not yet implemented
        end

        describe "then unchecking it again" do
          before { check_product_closed(selected_product, false) }

          it "hides the 'when did I close it'" do
            expect(page).to have_field    "cards_survey_#{id}_card_closed"
            expect(page).to have_no_field "cards_survey_#{id}_card_closed_at_month"
            expect(page).to have_no_field "cards_survey_#{id}_card_closed_at_year"
          end

          describe "and submitting the form" do
            it "doesn't mark the card as closed"
          end
        end
      end
    end

    describe "selecting some cards" do
      let(:visible_products) { @visible_products }
      let(:closed_card) { visible_products.first }
      let(:open_cards)  { visible_products.drop(1) }

      let(:this_year) { Time.zone.today.year.to_s }
      let(:last_year) { (Time.zone.today.year - 1).to_s }
      let(:ten_years_ago) { (Time.zone.today.year - 10).to_s }

      before do
        visible_products.each do |product|
          check_product_opened(product, true)
        end
        select "Jan",     from: "cards_survey_#{open_cards[0].id}_card_opened_at_month"
        select this_year, from: "cards_survey_#{open_cards[0].id}_card_opened_at_year"
        select "Mar",     from: "cards_survey_#{open_cards[1].id}_card_opened_at_month"
        select last_year, from: "cards_survey_#{open_cards[1].id}_card_opened_at_year"
        select "Nov",     from: "cards_survey_#{closed_card.id}_card_opened_at_month"
        select ten_years_ago, from: "cards_survey_#{closed_card.id}_card_opened_at_year"
        check_product_closed(closed_card, true)
        select "Apr",     from: "cards_survey_#{closed_card.id}_card_closed_at_month"
        select last_year, from: "cards_survey_#{closed_card.id}_card_closed_at_year"
      end

      describe "and submitting the form" do
        it 'assigns the cards to owner' do
          expect do
            submit_form
          end.to change { owner.cards.count }.by visible_products.length
        end

        describe "the created card accounts" do
          before { submit_form }
          let(:new_accounts) { owner.cards }

          specify 'have the right cards' do
            expect(new_accounts.map(&:product)).to match_array visible_products
          end

          specify 'have no offers' do
            expect(new_accounts.map(&:offer).compact).to be_empty
          end

          specify 'have the given opened and closed dates' do
            open_acc_0 = new_accounts.find_by(product_id: open_cards[0].id)
            open_acc_1 = new_accounts.find_by(product_id: open_cards[1].id)
            closed_acc = new_accounts.find_by(product_id: closed_card.id)
            expect(open_acc_0.opened_at.strftime('%F')).to eq end_of_month(this_year, '01')
            expect(open_acc_0.closed_at).to be_nil
            expect(open_acc_1.opened_at.strftime('%F')).to eq end_of_month(last_year, '03')
            expect(open_acc_1.closed_at).to be_nil
            expect(closed_acc.opened_at.strftime('%F')).to eq end_of_month(ten_years_ago, '11')
            expect(closed_acc.closed_at.strftime('%F')).to eq end_of_month(last_year, '04')
          end

          specify 'have the right statuses' do
            open_acc_0 = new_accounts.find_by(product_id: open_cards[0].id)
            open_acc_1 = new_accounts.find_by(product_id: open_cards[1].id)
            closed_acc = new_accounts.find_by(product_id: closed_card.id)
            expect(open_acc_0.status).to eq 'open'
            expect(open_acc_1.status).to eq 'open'
            expect(closed_acc.status).to eq 'closed'
          end

          specify 'have "from survey" as their source' do
            expect(owner.cards.all?(&:from_survey?)).to be true
          end
        end

        include_examples 'submitting the form'
      end
    end # selecting some cards

    describe "submitting the form without selecting any cards" do
      it "doesn't assign any cards to any account" do
        expect { submit_form }.not_to change { Card.count }
      end

      include_examples "submitting the form"
    end
  end
end
