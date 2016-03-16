require "rails_helper"

describe "as a new user" do
  subject { page }

  before do
    @account = create(:account)
    @main_passenger = create(
      :main_passenger_with_spending,
      account:         @account,
      first_name:     "Steve",
      has_added_cards: true
    )
    if has_companion
      if main_passenger_has_added_balances
        @main_passenger.update_attributes!(has_added_balances: true)
      end
      @companion = create(
        :companion_with_spending, 
        account:         @account,
        first_name:      "Pete",
        has_added_cards: true
      )
    end

    @currencies = create_list(:currency, 3)
    login_as @account, scope: :account
  end

  let(:has_companion) { false }
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

  shared_examples "mark survey as completed" do |opts={}|
    let(:passenger) { opts[:companion] ? @companion : @main_passenger }

    it "marks that the passenger has completed this part of the survey" do
      expect(passenger.has_added_balances?).to be_falsey
      submit_form
      expect(passenger.reload.has_added_balances?).to be_truthy
    end
  end

  shared_examples "balances survey" do |opts={}|
    let(:passenger) { opts[:companion] ? @companion : @main_passenger }

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
          it "creates a balance for the passenger and the currency" do
            expect{submit_form}.to change{passenger.balances.count}.by(1)
            balance = passenger.reload.balances.last
            expect(balance.currency).to eq currency
            expect(balance.passenger).to eq passenger
          end

          include_examples "mark survey as completed", opts
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
        balance = passenger.reload.balances.last
        expect(balance.currency).to eq currency
        expect(balance.value).to eq 50_000
      end
    end

    describe "clicking 'Submit' without adding any balances" do
      it "doesn't create any balances" do
        expect{submit_form}.not_to change{Balance.count}
      end

      include_examples "mark survey as completed", opts
    end
  end # shared_examples 'balances survey'

  describe "the 'main passenger' balances survey" do
    before { visit survey_balances_path(:main) }

    context "when I do not have a travel companion on my account" do
      let(:has_companion) { false }

      it "asks me about “your” balances" do
        is_expected.to have_content "Do you have any existing"
      end
    end

    context "when I have a travel companion on my account" do
      let(:has_companion) { true }
      let(:main_passenger_has_added_balances) { false }

      it "asks me for “Name's” cards" do
        is_expected.to have_content "Does Steve have any existing"
      end
    end

    describe "submitting the form" do
      before { submit_form }
      it "takes me to the next stage of the survey" do
        skip
        expect(current_path).to eq # ???
      end
    end

    include_examples "balances survey"
  end # the 'main passenger' balances survey

  describe "the 'companion' balances survey" do
    let(:has_companion) { true }
    let(:main_passenger_has_added_balances) { true }

    before { visit survey_balances_path(:companion) }

    it "asks me for “Companion's Name's” cards" do
      is_expected.to have_content "Does Pete have any existing"
    end

    describe "submitting the form" do
      before { submit_form }
      it "takes me to the next stage of the survey" do
        skip
        expect(current_path).to eq # ???
      end
    end

    include_examples "balances survey", companion: true
  end # the 'main passenger' balances survey
end
