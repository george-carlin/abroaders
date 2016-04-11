require "rails_helper"

describe "the balance survey page", :onboarding do
  subject { page }

  let!(:account) { create(:account) }
  let!(:me) { create(:person, account: account, onboarded_balances: onboarded) }

  before do
    @currencies = create_list(:currency, 3)
    create(:person, main: false, account: account) if already_has_companion
    login_as_account(account)
    visit survey_person_balances_path(me)
  end
  let(:submit_form) { click_button "Submit" }

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

  let(:onboarded) { false }
  let(:already_has_companion) { false }

  context "when the person has already completed this survey" do
    let(:onboarded) { true }
    it "redirects to my dashboard" do
      expect(current_path).to eq root_path
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

  describe "submitting the form" do
    before { submit_form }

    context "when I don't have a companion" do
      it "takes me to the new companion page" do
        expect(current_path).to eq new_companion_path
      end
    end

    context "when I have a companion" do
      let(:already_has_companion) { true }
      it "takes me to the readiness sureey" do
        expect(current_path).to eq survey_readiness_path
      end
    end

    it "marks this person as having completed the balances survey" do
      expect(me.reload.onboarded_balances?).to be true
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
        is_expected.to have_no_field balance_field(currency)
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

  describe "submitting a balance that contains commas", :js do
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
