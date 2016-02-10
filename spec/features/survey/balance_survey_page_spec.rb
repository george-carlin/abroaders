require "rails_helper"

describe "onboarding survey - existing balances page", focus: true do
  subject { page }

  include_context "logged in as new user"

  before do
    user.create_info!(
      attributes_for(:user_info, :completed_card_survey, user: nil)
    )
    @currencies = create_list(:currency, 3)
    visit balances_survey_path
  end

  let(:submit) { click_button "Submit" }

  shared_examples "mark survey as completed" do
    it "marks that the user has completed this part of the survey" do
      expect(user.has_completed_balances_survey?).to be_falsey
      submit
      user.reload
      expect(user.has_completed_balances_survey?).to be_truthy
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

  describe "clicking a check box next to a currency", js: true do
    let(:currency) { @currencies.first }

    before do
      within_currency(currency) do
        find("input[type='checkbox']").click
      end
    end

    it "shows a field to input my balance in that currency" do
      within_currency(currency) do
        is_expected.to have_field balance_field(currency)
      end
    end

    describe "and unchecking the check box" do
      before do
        within_currency(currency) do
          find("input[type='checkbox']").click
        end
      end

      it "hides the balance field" do
        is_expected.not_to have_field balance_field(currency)
      end
    end

    describe "and typing in a balance" do
      before { fill_in balance_field(currency), with: 50_000 }

      describe "and clicking 'Submit'" do
        it "creates a balance for the user and the currency" do
          expect{submit}.to change{user.balances.count}.by(1)
          balance = user.balances.last
          expect(balance.currency).to eq currency
          expect(balance.user).to eq user
        end

        include_examples "mark survey as completed"
      end

      describe "and unchecking the check box" do
        before do
          within_currency(currency) do
            find("input[type='checkbox']").click
          end
        end

        describe "and clicking 'submit'" do
          it "doesn't create any balances" do
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

  def currency_selector(currency)
    "##{dom_id(currency)}"
  end

  def within_currency(currency)
    within(currency_selector(currency)) { yield }
  end

  def balance_field(currency)
    :"currency_#{currency.id}_balance_value"
  end

end
