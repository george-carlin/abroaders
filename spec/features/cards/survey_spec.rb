require 'rails_helper'

RSpec.describe 'cards survey', :onboarding, :js do
  subject { page }

  let(:chase) { Bank.find_by_name!('Chase') }
  let(:citi) { Bank.find_by_name!('Citibank') }
  let(:banks) { [chase, citi] }

  let!(:hidden_product) { create(:card_product, :hidden) }

  let!(:visible_products) do
    [
      create(:card_product, :business, :visa,       bank: chase, name: 'Card 0'),
      create(:card_product, :personal, :mastercard, bank: chase, name: 'Card 1'),
      create(:card_product, :business, :mastercard, bank: citi,  name: 'Card 2'),
      create(:card_product, :personal, :visa,       bank: citi,  name: 'Card 3'),
      create(:card_product, :personal, :visa,       bank: citi,  name: 'Card 4'),
    ]
  end

  let(:account) { create_account(:eligible, onboarding_state: 'owner_cards') }
  let(:owner) { account.owner }

  before do
    login_as account.reload
    visit survey_person_cards_path(owner)
  end

  let(:name) { owner.first_name }
  let(:submit_form) { click_button 'Save and continue' }

  def check_product_opened(product, checked)
    field = "cards_survey_#{product.id}_card_opened"
    checked ? check(field) : uncheck(field)
  end

  def check_product_closed(product, checked)
    field = "cards_survey_#{product.id}_card_closed"
    checked ? check(field) : uncheck(field)
  end

  def expand_banks
    banks.each do |bank|
      click_on bank.name.upcase
      sleep 0.5
    end
  end

  example "initial page layout" do
    expect(page).to have_no_sidebar
    expect(page).to have_content \
      'Do you have any credit cards that earn points or miles?'
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
    # doesn't initially list cards:
    expect(page).to have_no_selector ".card-survey-checkbox"
  end

  example "clicking 'No'" do
    click_button "No"

    expect(page).to have_no_content \
      'Do you have any credit cards that earn points or miles?'
    expect(page).to have_no_button "Yes"
    expect(page).to have_no_button "No"
    expect(page).to have_content \
      "You have never had a card that earns points or miles"
    expect(page).to have_button "Confirm"
    expect(page).to have_button "Back"

    expect do
      click_button "Confirm"
    end.to change { Card.count }.by(0)

    expect(account.reload.onboarding_state).to eq "owner_balances"
    expect(current_path).to eq survey_person_balances_path(owner)
  end

  example "clicking 'No' and going back" do
    click_button "No"
    click_button "Back"
    expect(page).to have_content \
      'Do you have any credit cards that earn points or miles?'
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

    it "shows products" do
      # products are grouped by bank, then B/P
      banks.each do |bank|
        expect(page).to have_selector "h2", text: bank.name.upcase
        within "#bank-collapse-#{bank.id}" do
          %w[personal business].each do |type|
            expect(page).to have_selector "h4", text: "#{type.capitalize} Cards"
            expect(page).to have_selector "#bank_#{bank.id}_cards"
            expect(page).to have_selector "#bank_#{bank.id}_#{type}_cards"

            # page has only has one 'group' per bank and b/p (bug fix)
            expect(all("[id='bank_#{bank.id}_cards']").length).to eq 1
            expect(all("[id='bank_#{bank.id}_personal_cards']").length).to eq 1
            expect(all("[id='bank_#{bank.id}_business_cards']").length).to eq 1
          end
        end
      end

      # page has a checkbox for each card product:
      visible_products.each do |product|
        expect(page).to have_field :"cards_survey_#{product.id}_card_opened"
      end

      # page initially has no inputs for opened/closed dates:
      %w[
        opened_on_month opened_on_year closed closed_on_month
        closed_on_year
      ].each do |attr|
        expect(page).to have_no_selector(".cards_survey_card_#{attr}")
      end
    end

    it "doesn't show cards which the admin has opted to hide" do
      expect(page).to have_no_selector "#card_product_#{hidden_product.id}"
    end

    describe "selecting a card" do
      let(:selected_product) { visible_products[0] }
      let(:id) { selected_product.id }

      before { check_product_opened(selected_product, true) }

      it "asks when the card was opened" do
        expect(page).to have_field "cards_survey_#{id}_card_opened_on_month"
        expect(page).to have_field "cards_survey_#{id}_card_opened_on_year"
      end

      example "unselecting it again" do
        check_product_opened(selected_product, false)

        # hides all other inputs
        expect(page).to have_no_field "cards_survey_#{id}_card_opened_on_month"
        expect(page).to have_no_field "cards_survey_#{id}_card_opened_on_year"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed_on_month"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed_on_year"
      end

      example "checking/unchecking 'I closed the card'" do
        # doesn't initially show closed_on inputs:
        expect(page).to have_field    "cards_survey_#{id}_card_closed"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed_on_month"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed_on_year"

        check_product_closed(selected_product, true)

        # shows closed_on inputs:
        expect(page).to have_field "cards_survey_#{id}_card_closed"
        expect(page).to have_field "cards_survey_#{id}_card_closed_on_month"
        expect(page).to have_field "cards_survey_#{id}_card_closed_on_year"

        # unchecking it again:
        check_product_closed(selected_product, false)

        # hides closed_on inputs:
        expect(page).to have_field    "cards_survey_#{id}_card_closed"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed_on_month"
        expect(page).to have_no_field "cards_survey_#{id}_card_closed_on_year"
      end
    end

    describe 'selecting some cards' do
      let(:closed_prod) { visible_products.first }
      let(:opened_prod) { visible_products.last }

      let(:this_year) { Time.zone.today.year }
      let(:last_year) { this_year - 1 }

      before do
        check_product_opened(opened_prod, true)
        select 'Jan', from: "cards_survey_#{opened_prod.id}_card_opened_on_month"
        select this_year, from: "cards_survey_#{opened_prod.id}_card_opened_on_year"

        check_product_opened(closed_prod, true)
        select 'Apr', from: "cards_survey_#{closed_prod.id}_card_opened_on_month"
        select last_year, from: "cards_survey_#{closed_prod.id}_card_opened_on_year"
        check_product_closed(closed_prod, true)
        select 'Nov', from: "cards_survey_#{closed_prod.id}_card_closed_on_month"
        select last_year, from: "cards_survey_#{closed_prod.id}_card_closed_on_year"
      end

      describe 'and submitting the form' do
        it 'creates the cards' do
          expect do
            submit_form
          end.to change { owner.card_accounts.count }.by(2)

          expect(owner.card_accounts.count).to eq 2
          expect(owner.card_accounts.where(closed_on: nil).count).to eq 1

          open_card = owner.cards.find_by!(card_product_id: opened_prod)
          closed_card = owner.cards.find_by!(card_product_id: closed_prod)

          expect(open_card.offer).to be_nil
          expect(closed_card.offer).to be_nil

          # the cards have the right opened and closed dates
          expect(open_card.opened_on).to eq Date.new(this_year, 1)
          expect(open_card.closed_on).to be_nil

          expect(closed_card.opened_on).to eq Date.new(last_year, 4)
          expect(closed_card.closed_on).to eq Date.new(last_year, 11)
        end
      end
    end # selecting some cards

    describe "submitting the form without selecting any cards" do
      it "doesn't assign any cards to any account" do
        expect { submit_form }.not_to change { Card.count }
      end
    end
  end
end
