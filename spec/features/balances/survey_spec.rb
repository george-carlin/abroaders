require "rails_helper"

describe "the balance survey page", :onboarding do
  subject { page }

  include_context "set erik's email ENV var"

  let!(:onboarded_type) { true }
  let!(:onboarded_travel_plans) { true }

  before do
    @account  = create(
                  :account,
                  :onboarded_travel_plans => onboarded_travel_plans,
                  :onboarded_type         => onboarded_type,
                )
    @me = account.main_passenger
    @me.update_attributes!(onboarded_balances: onboarded)
    @currencies = create_list(:currency, 3)
    login_as_account(account)
    visit survey_person_balances_path(me)
  end
  let(:submit_form) { click_button "Submit" }

  let(:account) { @account }
  let(:me)      { @me }

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

  it { is_expected.to have_title full_title("Balances") }

  it "doesn't show the sidebar" do
    is_expected.to have_no_selector "#menu"
  end

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

  it "shows a list of currencies with a checkbox next to each name" do
    @currencies.each do |currency|
      is_expected.to have_content currency.name
      within_currency(currency) do
        is_expected.to have_selector "input[type='checkbox']"
      end
    end
  end

  it { is_expected.to have_field :balances_survey_award_wallet_email }

  describe "submitting the form" do
    before do
      if i_am_eligible_to_apply
        @me.eligible_to_apply!
      end

      if i_am_the_partner
        @me.update_attributes!(main: false)
        Person.create!(main: true, first_name: "X", account: @account)
      elsif i_have_a_partner
        @partner = @account.create_companion!(first_name: "Somebody")
        if partner_is_eligible_to_apply
          @partner.eligible_to_apply!
        end
      end

      pre_submit
    end

    let(:i_am_eligible_to_apply) { false }
    let(:i_am_the_partner) { false }
    let(:i_have_a_partner) { false }
    let(:partner) { @partner }

    let(:pre_submit) { nil }

    context "when I am the main person on the account" do
      let(:i_am_the_partner) { false }

      context "and I am eligible to apply for cards" do
        let(:i_am_eligible_to_apply) { true }
        it "takes me to the readiness survey" do
          submit_form
          expect(current_path).to eq new_person_readiness_status_path(me)
        end

        include_examples "don't send any emails"
      end

      context "and I am ineligible to apply for cards" do
        let(:i_am_eligible_to_apply) { false }

        context "and I have a partner on the account" do
          let(:i_have_a_partner) { true }
          context "who is eligible to apply for cards" do
            let(:partner_is_eligible_to_apply) { true }
            it "takes me to the partner's spending survey" do
              submit_form
              expect(current_path).to eq new_person_spending_info_path(partner)
            end

            include_examples "don't send any emails"
          end

          context "who is ineligible to apply for cards" do
            let(:partner_is_eligible_to_apply) { false }
            it "takes me to the partner's balances survey" do
              submit_form
              expect(current_path).to eq survey_person_balances_path(partner)
            end

            include_examples "don't send any emails"
          end
        end

        context "and I don't have a partner on the account" do
          it "takes me to my dashboard" do
            submit_form
            expect(current_path).to eq root_path
          end

          include_examples "send survey complete email to admin"
        end
      end
    end

    context "when I am the partner on the account" do
      let(:i_am_the_partner) { true }

      context "and I am eligible to apply for cards" do
        let(:i_am_eligible_to_apply) { true }
        it "takes me to the readiness survey" do
          submit_form
          expect(current_path).to eq new_person_readiness_status_path(me)
        end

        include_examples "don't send any emails"
      end

      context "and I am ineligible to apply for cards" do
        let(:i_am_eligible_to_apply) { false }

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
