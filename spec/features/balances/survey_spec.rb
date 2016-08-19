require "rails_helper"

describe "the balance survey page", :onboarding, :js do
  subject { page }

  include_context "set admin email ENV var"

  before do
    @account = create(:account, onboarded_travel_plans: true, onboarded_type: true)
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

  it { is_expected.to have_title full_title("Balances") }

  it "doesn't show the sidebar" do
    is_expected.to have_no_selector "#menu"
  end

  it "asks if I have any balances over 5,000" do
    expect(page).to have_content "Does George have any points balances greater than 5,000?"
    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
  end

  describe "clicking 'No'" do
    before { click_button "No" }

    it "asks to confirm" do
      expect(page).to have_no_content "Does George have any points balances greater than 5,000?"
      expect(page).to have_no_button "Yes"
      expect(page).to have_no_button "No"
      expect(page).to have_content "George has no points balances greater than 5,000"
      expect(page).to have_button "Confirm"
      expect(page).to have_button "Back"
    end

    describe "and clicking 'Confirm'" do
      let(:submit_form) { click_button "Confirm" }

      it "doesn't create any balances for me" do
        expect{submit_form}.not_to change{Balance.count}
      end
    end

    describe "and clicking 'Back'" do
      before { click_button "Back" }

      it "goes back" do
        expect(page).to have_content "Does George have any points balances greater than 5,000?"
        expect(page).to have_button "Yes"
        expect(page).to have_button "No"
        expect(page).to have_no_content "George has no points balances greater than 5,000"
        expect(page).to have_no_button "Confirm"
        expect(page).to have_no_button "Back"
      end
    end
  end

  describe "clicking 'Yes'" do
    before { click_button "Yes" }

    it "shows a list of currencies with a checkbox next to each name" do
      @currencies.each do |currency|
        expect(page).to have_content currency.name
        within_currency(currency) do
          expect(page).to have_selector "input[type='checkbox']"
        end
      end
    end

    it { is_expected.to have_field :balances_survey_award_wallet_email }

    example "submitting form marks me as having completed the balances survey" do
      submit_form
      expect(me.reload.onboarded_balances?).to be true
    end

    example "providing an award wallet email" do
      fill_in :balances_survey_award_wallet_email, with: "a@b.com"
      submit_form
      expect(me.reload.award_wallet_email).to eq "a@b.com"
    end

    describe "clicking a check box next to a currency" do
      let(:currency) { @currencies.first }

      before { currency_check_box(currency).click }

      it "shows a field to input my balance in that currency" do
        within_currency(currency) do
          expect(page).to have_field balance_field(currency)
        end
      end

      describe "and unchecking the check box" do
        before { currency_check_box(currency).click }

        it "hides the balance field" do
          expect(page).to have_no_field balance_field(currency)
        end
      end

      describe "and typing in a balance" do
        before { fill_in balance_field(currency), with: 50_000 }

        describe "and clicking 'Submit'" do
          it "creates a balance for the person in this currency" do
            expect{submit_form}.to change{me.balances.count}.by(1)
            balance = me.reload.balances.last
            expect(balance.currency).to eq currency
            expect(balance.person).to eq me
          end
        end

        describe "and unchecking the check box" do
          before { currency_check_box(currency).click }

          describe "and clicking 'submit'" do
            it "doesn't create a balance for that currency" do
              expect{submit_form}.not_to change{Balance.count}
            end
          end
        end
      end
    end

    describe "submitting a balance that contains commas" do
      let(:currency) { @currencies.first }
      before do
        currency_check_box(currency).click
        fill_in balance_field(currency), with: "50,000"
        submit_form
      end

      it "strips the commas before saving" do
        balance = me.reload.balances.last
        expect(balance.currency).to eq currency
        expect(balance.value).to eq 50_000
      end
    end

    describe "clicking 'Submit' without adding any balances" do
      it "doesn't create any balances" do
        expect{submit_form}.not_to change{Balance.count}
      end
    end
  end
end
