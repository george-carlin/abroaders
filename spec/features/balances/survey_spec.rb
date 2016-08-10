require "rails_helper"

describe "the balance survey page", :onboarding, :js do
  subject { page }

  include_context "set admin email ENV var"

  let!(:onboarded_type) { true }
  let!(:onboarded_travel_plans) { true }

  before do
    @account  = create(
                  :account,
                  :onboarded_travel_plans => onboarded_travel_plans,
                  :onboarded_type         => onboarded_type,
                )
    if i_am_owner
      @me = account.owner
      if i_have_a_companion
        @companion = create(:person, main: false, account: account, eligible: companion_is_eligible)
      end
    else
      @me = create(:person, main: false, account: account)
    end
    @me.update_attributes!(
      eligible: i_am_eligible,
      first_name: "George",
      onboarded_balances: onboarded,
    )
    @currencies = create_list(:currency, 3)
    login_as_account(account)

    visit survey_person_balances_path(me)
  end

  let(:submit_form) { click_button "Submit" }

  let(:i_am_eligible)         { false }
  let(:i_am_owner)            { false }
  let(:i_have_a_companion)    { false }
  let(:companion_is_eligible) { false }

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

  let(:onboarded) { false }

  shared_examples "complete survey" do
    it "marks me as having completed the balances survey" do
      submit_form
      expect(me.reload.onboarded_balances?).to be true
    end

    context "when I am the account owner" do
      let(:i_am_owner) { true }
      it "tracks an event on Intercom", :intercom do
        expect{submit_form}.to \
          track_intercom_event("obs_balances_own").
          for_email(account.email)
      end
    end

    context "when I am the companion" do
      let(:i_am_owner) { false }
      it "tracks an event on Intercom", :intercom do
        expect{submit_form}.to \
          track_intercom_event("obs_balances_com").
          for_email(account.email)
      end
    end
  end

  it { is_expected.to have_title full_title("Balances") }

  it { is_expected.to have_no_sidebar }

  context "when I haven't completed the travel plans survey" do
    let(:onboarded_travel_plans) { false }
    it "redirects me to the travel plan survey" do
      expect(current_path).to eq new_travel_plan_path
    end
  end

  context "when I haven't chosen an account type" do
    let(:onboarded_type) { false }
    it "redirects me to the account type page" do
      expect(current_path).to eq type_account_path
    end
  end

  context "when the person has already completed this survey" do
    let(:onboarded) { true }
    it "redirects to my dashboard" do
      expect(current_path).to eq root_path
    end
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

      include_examples "complete survey"
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

    describe "submitting the form" do
      before { pre_submit }

      let(:pre_submit) { nil }

      context "when I am the account owner" do
        let(:i_am_owner) { true }

        context "and I am eligible to apply for cards" do
          let(:i_am_eligible) { true }
          it "takes me to the readiness survey" do
            submit_form
            expect(current_path).to eq new_person_readiness_status_path(me)
          end

          include_examples "don't send any emails"
        end

        context "and I am ineligible to apply for cards" do
          let(:i_am_eligible) { false }

          context "and I have a companion" do
            let(:i_have_a_companion) { true }
            context "who is eligible to apply for cards" do
              let(:companion_is_eligible) { true }
              it "takes me to the companion's spending survey" do
                submit_form
                expect(current_path).to eq new_person_spending_info_path(companion)
              end

              include_examples "don't send any emails"
            end

            context "who is ineligible to apply for cards" do
              let(:companion_is_eligible) { false }
              it "takes me to the companion's balances survey" do
                submit_form
                expect(current_path).to eq survey_person_balances_path(companion)
              end

              include_examples "don't send any emails"
            end
          end

          context "and I don't have a companion" do
            it "takes me to my dashboard" do
              submit_form
              expect(current_path).to eq root_path
            end

            include_examples "send survey complete email to admin"
          end
        end
      end

      context "when I am the companion" do
        let(:i_am_owner) { false }

        context "and I am eligible to apply for cards" do
          let(:i_am_eligible) { true }
          it "takes me to the readiness survey" do
            submit_form
            expect(current_path).to eq new_person_readiness_status_path(me)
          end

          include_examples "don't send any emails"
        end

        context "and I am ineligible to apply for cards" do
          let(:i_am_eligible) { false }

          it "takes me to the dashboard" do
            submit_form
            expect(current_path).to eq root_path
          end

          include_examples "send survey complete email to admin"
        end
      end

      it "marks me as having completed the balances survey" do
        submit_form
        expect(me.reload.onboarded_balances?).to be true
      end

      context "providing an award wallet email" do
        let(:pre_submit) do
          fill_in :balances_survey_award_wallet_email, with: "a@b.com"
        end

        it "saves the email" do
          submit_form
          expect(me.reload.award_wallet_email).to eq "a@b.com"
        end
      end
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

        include_examples "complete survey"
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

      include_examples "complete survey"
    end
  end
end
