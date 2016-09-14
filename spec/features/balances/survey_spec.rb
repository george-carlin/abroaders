require "rails_helper"

describe "the balance survey page", :onboarding, :js do
  subject { page }

  include_context "set admin email ENV var"

  before do
    @account = create(:account, :onboarded_type)
    @me = account.owner
    @me.update_attributes!(first_name: "George")
    @currencies = create_list(:currency, 3)
    login_as_account(account)

    visit survey_person_balances_path(@me)
  end

  let(:submit_form) { click_button "Submit" }

  let(:account)   { @account }
  let(:me)        { @me }
  let(:companion) { @companion }

  def currency_selector(currency)
    "##{dom_id(currency)}"
  end

  def within_currency(currency)
    within(currency_selector(currency)) { yield }
  end

  def balance_field(currency)
    :"currency_#{currency.id}_balance_value"
  end

  def currency_check_box(currency)
    within_currency(currency) do
      find("input[type='checkbox']")
    end
  end

  example "initial page layout" do
    expect(page).to have_title full_title("Balances")
    expect(page).to have_no_sidebar
    expect(page).to have_content "Does George have any points balances greater than 5,000?"
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
  end

  example "clicking 'No' asks for confirmation" do
    click_button "No"
    expect(page).to have_no_content "Does George have any points balances greater than 5,000?"
    expect(page).to have_no_button "Yes"
    expect(page).to have_no_button "No"
    expect(page).to have_content "George has no points balances greater than 5,000"
    expect(page).to have_button "Confirm"
    expect(page).to have_button "Back"

    click_button "Back"
    expect(page).to have_content "Does George have any points balances greater than 5,000?"
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
    expect(page).to have_no_content "George has no points balances greater than 5,000"
    expect(page).to have_no_button "Confirm"
    expect(page).to have_no_button "Back"
  end

  example "clicking 'No' and confirming" do
    click_button "No"
    expect{click_button "Confirm"}.not_to change{Balance.count}
    expect(me.reload.onboarded_balances?).to be true
  end

  example "clicking 'Yes' shows list of currencies" do
    click_button "Yes"
    @currencies.each do |currency|
      expect(page).to have_content currency.name
      within_currency(currency) do
        expect(page).to have_selector "input[type='checkbox']"
      end
    end
  end

  example "clicking 'Yes' asks for AwardWallet email" do
    click_button "Yes"
    expect(page).to have_field :balances_survey_award_wallet_email
  end

  example "providing an award wallet email" do
    click_button "Yes"
    fill_in :balances_survey_award_wallet_email, with: "a@b.com"
    submit_form
    expect(me.reload.award_wallet_email).to eq "a@b.com"
  end

  example "hiding and showing a currency's value input" do
    currency = @currencies.first

    click_button "Yes"

    currency_check_box(currency).click
    within_currency(currency) do
      expect(page).to have_field balance_field(currency)
    end

    currency_check_box(currency).click
    expect(page).to have_no_field balance_field(currency)
  end

  example "submitting a balance" do
    currency = @currencies.first
    click_button "Yes"
    currency_check_box(currency).click
    fill_in balance_field(currency), with: 50_000
    expect{submit_form}.to change{me.balances.count}.by(1)
    balance = me.reload.balances.last
    expect(balance.currency).to eq currency
    expect(balance.person).to eq me
    expect(balance.value).to eq 50_000

    expect(me.reload.onboarded_balances?).to be true
  end

  example "clicking 'submit' after unchecking a balance" do
    currency = @currencies.first
    click_button "Yes"
    currency_check_box(currency).click
    fill_in balance_field(currency), with: 50_000
    # Uncheck the box and the text field will be hidden
    currency_check_box(currency).click
    # Make sure it doesn't create a balance for the currency you've now unchecked:
    expect{submit_form}.not_to change{Balance.count}
  end

  example "submitting a balance that contains commas" do
    currency = @currencies.first
    click_button "Yes"
    currency_check_box(currency).click
    fill_in balance_field(currency), with: "50,000"
    expect{submit_form}.to change{me.balances.count}.by(1)
    balance = me.reload.balances.last
    expect(balance.value).to eq 50_000
  end

  example "clicking 'Yes' then submitting without adding any balances" do
    click_button "Yes"
    expect{submit_form}.not_to change{Balance.count}
    expect(me.reload.onboarded_balances?).to be true
  end

  example "tracking an intercom event when person is account owner" do
    click_button "Yes"
    expect{submit_form}.to track_intercom_event("obs_balances_own").for_email(account.email)
  end

  describe "when person is account companion" do
    before do
      @me.update_attributes!(onboarded_balances: true)
      @companion = create(:companion, account: account)
      visit survey_person_balances_path(@companion)
    end

    example "tracking an intercom event when person is companion" do
      click_button "Yes"
      expect{submit_form}.to track_intercom_event("obs_balances_com").for_email(account.email)
    end
  end
end
