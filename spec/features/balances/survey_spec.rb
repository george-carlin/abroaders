require 'rails_helper'

RSpec.describe 'the balance survey page', :onboarding, :js do
  subject { page }

  let(:account) { create_account(onboarding_state: 'owner_balances') }
  let(:owner)   { account.owner }
  let(:name)    { owner.first_name }
  let!(:currencies) { Array.new(3) { create_currency } }
  before do
    @hidden_currency = create_currency(shown_on_survey: false)
    login_as_account(account)

    visit survey_person_balances_path(owner)
  end

  let(:submit_form) { click_button "Save and continue" }

  let(:companion) { @companion }

  def within_currency(currency)
    within("#currency_#{currency.id}") { yield }
  end

  def balance_field(currency)
    :"currency_#{currency.id}_balance_value"
  end

  def currency_check_box(currency)
    within_currency(currency) do
      find("input[type='checkbox']")
    end
  end

  let(:confirmation) { 'You have no existing points or miles balances' }

  example "initial page layout" do
    expect(page).to have_title full_title('Points and Miles')
    expect(page).to have_no_sidebar
    expect(page).to have_link 'Yup'
    expect(page).to have_link 'Nope'
  end

  example "doesn't show currencies which has shown_on_survey=false" do
    expect(page).to have_no_css("#currency_#{@hidden_currency.id}_balance")
  end

  example "clicking 'No' asks for confirmation" do
    click_link 'Nope'
    expect(page).to have_no_link 'Yup'
    expect(page).to have_no_link 'Nope'
    expect(page).to have_content confirmation
    expect(page).to have_button 'Confirm'
    expect(page).to have_link 'Back'

    click_link 'Back'
    expect(page).to have_link 'Yup'
    expect(page).to have_link 'Nope'
    expect(page).to have_no_content confirmation
    expect(page).to have_no_button "Confirm"
    expect(page).to have_no_link "Back"
  end

  example "clicking 'No' and confirming" do
    click_link 'Nope'
    expect { click_button "Confirm" }.not_to change { Balance.count }
  end

  example "clicking 'Yes' shows list of currencies" do
    click_link 'Yup'
    currencies.each do |currency|
      expect(page).to have_content currency.name
      within_currency(currency) do
        expect(page).to have_selector "input[type='checkbox']"
      end
    end
  end

  example "hiding and showing a currency's value input" do
    currency = currencies.first

    click_link 'Yup'

    currency_check_box(currency).click
    within_currency(currency) do
      expect(page).to have_field balance_field(currency)
    end

    currency_check_box(currency).click
    expect(page).to have_no_field balance_field(currency)
  end

  example "submitting a balance" do
    currency = currencies.first
    click_link 'Yup'
    currency_check_box(currency).click
    fill_in balance_field(currency), with: 50_000
    fill_in balance_field(currency), with: 50_000
    expect { submit_form }.to change { owner.balances.count }.by(1)
    balance = owner.reload.balances.last
    expect(balance.currency).to eq currency
    expect(balance.person).to eq owner
    expect(balance.value).to eq 50_000
  end

  example "clicking 'submit' after unchecking a balance" do
    currency = currencies.first
    click_link 'Yup'
    currency_check_box(currency).click
    fill_in balance_field(currency), with: 50_000
    # Uncheck the box and the text field will be hidden
    currency_check_box(currency).click
    # Make sure it doesn't create a balance for the currency you've now unchecked:
    expect { submit_form }.not_to change { Balance.count }
  end

  example 'failed submit' do
    currency = currencies.first
    other_currencies = currencies - [ currency ]

    click_link 'Yup'
    currency_check_box(currency).click
    fill_in balance_field(currency), with: -1
    expect { submit_form }.not_to change { [ Balance.count, current_path ] }
    # balance form should still be visible with the fields unchanged:
    other_currencies.each do |curr|
      expect(page).to have_field "currency_#{curr.id}_balance", checked: false
      expect(page).to have_no_field "currency_#{curr.id}_balance_value"
    end

    expect(page).to have_field "currency_#{currency.id}_balance", checked: true
    expect(page).to have_field "currency_#{currency.id}_balance_value", with: -1
  end

  example "clicking 'Yes' then submitting without adding any balances" do
    click_link 'Yup'
    expect { submit_form }.not_to change { Balance.count }
  end
end
