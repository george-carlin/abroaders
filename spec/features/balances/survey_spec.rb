require "rails_helper"

describe "the balance survey page", :onboarding, :js do
  subject { page }

  let(:account) { create(:account, onboarding_state: "owner_balances") }
  let(:owner)   { account.owner }
  let(:name)    { owner.first_name }
  let!(:currencies) { create_list(:currency, 3) }
  before do
    @hidden_currency = create(:currency, shown_on_survey: false)
    login_as_account(account)

    visit survey_person_balances_path(owner)
  end

  let(:submit_form) { click_button "Save and continue" }

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
    expect(page).to have_content "Does #{name} have any points balances greater than 5,000?"
    expect(page).to have_link "Yes"
    expect(page).to have_link "No"
  end

  example "doesn't show currencies which has shown_on_survey=false" do
    expect(page).to have_no_css("#currency_#{@hidden_currency.id}_balance")
  end

  example "clicking 'No' asks for confirmation" do
    click_link "No"
    expect(page).to have_no_content "Does #{name} have any points balances greater than 5,000?"
    expect(page).to have_no_link "Yes"
    expect(page).to have_no_link "No"
    expect(page).to have_content "#{name} has no points balances greater than 5,000"
    expect(page).to have_button "Confirm"
    expect(page).to have_button "Back"

    click_button "Back"
    expect(page).to have_content "Does #{name} have any points balances greater than 5,000?"
    expect(page).to have_link "Yes"
    expect(page).to have_link "No"
    expect(page).to have_no_content "#{name} has no points balances greater than 5,000"
    expect(page).to have_no_button "Confirm"
    expect(page).to have_no_button "Back"
  end

  example "clicking 'No' and confirming" do
    click_link "No"
    expect { click_button "Confirm" }.not_to change { Balance.count }
  end

  example "clicking 'Yes' shows list of currencies" do
    click_link "Yes"
    currencies.each do |currency|
      expect(page).to have_content currency.name
      within_currency(currency) do
        expect(page).to have_selector "input[type='checkbox']"
      end
    end
  end

  example "clicking 'Yes' asks for AwardWallet email" do
    click_link "Yes"
    expect(page).to have_field :balances_survey_award_wallet_email
  end

  example "providing an award wallet email" do
    click_link "Yes"
    fill_in :balances_survey_award_wallet_email, with: "a@b.com"
    submit_form
    expect(owner.reload.award_wallet_email).to eq "a@b.com"
  end

  example "hiding and showing a currency's value input" do
    currency = currencies.first

    click_link "Yes"

    currency_check_box(currency).click
    within_currency(currency) do
      expect(page).to have_field balance_field(currency)
    end

    currency_check_box(currency).click
    expect(page).to have_no_field balance_field(currency)
  end

  example "submitting a balance" do
    currency = currencies.first
    click_link "Yes"
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
    click_link "Yes"
    currency_check_box(currency).click
    fill_in balance_field(currency), with: 50_000
    # Uncheck the box and the text field will be hidden
    currency_check_box(currency).click
    # Make sure it doesn't create a balance for the currency you've now unchecked:
    expect { submit_form }.not_to change { Balance.count }
  end

  example "submitting a balance that contains commas" do
    currency = currencies.first
    click_link "Yes"
    currency_check_box(currency).click
    fill_in balance_field(currency), with: "50,000"
    expect { submit_form }.to change { owner.balances.count }.by(1)
    balance = owner.reload.balances.last
    expect(balance.value).to eq 50_000
  end

  example "clicking 'Yes' then submitting without adding any balances" do
    click_link "Yes"
    expect { submit_form }.not_to change { Balance.count }
  end

  example "tracking an intercom event when person is account owner" do
    click_link "Yes"
    expect { submit_form }.to track_intercom_event("obs_balances_own").for_email(account.email)
  end

  describe "when person is owner, and account has a companion" do
    before { create(:companion, account: account) }

    it "doesn't send a 'profile complete' email to the admin" do
      click_link "Yes"
      expect { submit_form }.not_to change { ApplicationMailer.deliveries.last }
    end
  end

  # TODO
  skip "tracking an intercom event when person is companion" do
    click_link "Yes"
    expect { submit_form }.to track_intercom_event("obs_balances_com").for_email(account.email)
  end
end
