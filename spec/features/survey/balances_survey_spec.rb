require "rails_helper"

describe "balances survey" do
  subject { page }

  include_context "logged in as new user"

  before do
    user.create_survey!(
      attributes_for(:survey, :completed_card_survey, user: nil)
    )
    @currencies = create_list(:currency, 3)
    visit survey_balances_path
  end

  let(:submit) { click_button "Submit" }

  shared_examples "mark survey as completed" do
    it "marks that the user has completed this part of the survey" do
      expect(user.has_added_balances?).to be_falsey
      submit
      expect(user.reload.has_added_balances?).to be_truthy
    end
  end

  it "shows a list of currencies with a checkbox next to each name" do
    @currencies.each do |currency|
      is_expected.to have_content currency.name
      within_currency(currency) do
        is_expected.to have_selector "input[type='checkbox']"
      end
    end
  end

  describe "clicking a check box next to a currency", :js do
    let(:currency) { @currencies.first }

    before { currency_check_box(currency).click }

    it "shows a field to input my balance in that currency" do
      within_currency(currency) do
        is_expected.to have_field balance_field(currency)
      end
    end

    describe "and unchecking the check box" do
      before { currency_check_box(currency).click }

      it "hides the balance field" do
        is_expected.not_to have_field balance_field(currency)
      end
    end

    describe "and typing in a balance" do
      before { fill_in balance_field(currency), with: 50_000 }

      describe "and clicking 'Submit'" do
        it "creates a balance for the user and the currency" do
          expect{submit}.to change{user.balances.count}.by(1)
          balance = user.reload.balances.last
          expect(balance.currency).to eq currency
          expect(balance.user).to eq user
        end

        include_examples "mark survey as completed"
      end

      describe "and unchecking the check box" do
        before { currency_check_box(currency).click }

        describe "and clicking 'submit'" do
          it "doesn't create a balance for that currency" do
            expect{submit}.not_to change{Balance.count}
          end
        end
      end
    end
  end

  describe "clicking 'Submit' without adding any balances" do
    it "doesn't create any balances" do
      expect{submit}.not_to change{Balance.count}
    end

    include_examples "mark survey as completed"
  end

  describe "submitting a blank balance input", :js do
    before do
      currency_check_box(@currencies[0]).click
      currency_check_box(@currencies[1]).click
      fill_in balance_field(@currencies[0]), with: ""
      fill_in balance_field(@currencies[1]), with: 5000
    end

    it "doesn't create a balance for that currency" do
      expect{submit}.to change{user.balances.count}.by(1)
      expect(user.balances.first.currency).to eq @currencies[1]
    end
  end

  describe "submitting a negative balance", :js do
    before do
      currency_check_box(@currencies[0]).click
      currency_check_box(@currencies[1]).click
      fill_in balance_field(@currencies[0]), with: -5000
      fill_in balance_field(@currencies[1]), with: 5000
    end

    it "doesn't create any balances" do
      expect{submit}.not_to change{Balance.count}
    end

    it "shows the form again with an error message" do
      submit
      expect(page).to have_selector ".balances_survey"
      expect(page).to have_selector ".alert.alert-danger"
    end

    it "preserves the values I'd previously submitted in the form" do
      expect(currency_check_box(@currencies[0])).to be_checked
      expect(find("##{balance_field(@currencies[0])}").value).to eq "-5000"
      expect(currency_check_box(@currencies[1])).to be_checked
      expect(find("##{balance_field(@currencies[1])}").value).to eq "5000"
      expect(currency_check_box(@currencies[2])).not_to be_checked
    end
  end

  describe "submitting a balance of 0 for a currency", :js do
    before do
      currency_check_box(@currencies[0]).click
      currency_check_box(@currencies[1]).click
      fill_in balance_field(@currencies[0]), with: 15000
      fill_in balance_field(@currencies[1]), with: 0
    end

    it "doesn't create a balance for that currency" do
      expect{submit}.to change{user.balances.count}.by(1)
      expect(user.balances.first.currency).to eq @currencies[0]
    end
  end

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

end
