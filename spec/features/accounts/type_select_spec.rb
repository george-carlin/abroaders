require "rails_helper"

describe "account type select page", :js, :onboarding do
  subject { page }

  let!(:account) do
    create(:account, onboarded_travel_plans: onboarded_travel_plans)
  end
  let!(:me) { account.people.first }

  let(:onboarded_travel_plans) { true }

  before do
    login_as_account(account)
    extra_setup
    visit type_account_path
  end

  let(:partner_btn) { t("accounts.type.sign_up_for_couples_earning") }
  let(:solo_btn)    { "Sign up for solo earning" }

  let(:extra_setup) { nil }

  def self.it_marks_survey_as_complete
    it "marks my account as having completed this part of the survey" do
      click_confirm
      expect(account.reload.onboarded_type?).to be true
    end
  end

  def self.it_doesnt_mark_survey_as_complete
    it "doesn't mark my account as having completed this part of the survey" do
      expect(account.reload.onboarded_type?).to be false
    end
  end

  it { is_expected.to have_title full_title("Select Account Type") }

  it "gives me the option to choose a 'Solo' or 'Partner' account" do
    is_expected.to have_button solo_btn
    is_expected.to have_button partner_btn
    is_expected.to have_field :partner_account_partner_first_name
  end

  it "has no sidebar" do
    expect(page).to have_no_sidebar
  end

  context "when I haven't completed the travel plan survey" do
    let(:onboarded_travel_plans) { false }
    it "redirects me to the travel plan form" do
      expect(current_path).to eq new_travel_plan_path
    end
  end

  context "when I skipped adding a travel plan" do
    it { is_expected.to have_content "Abroaders will help you earn the right points for your next trip" }
  end

  context "when I added a travel plan" do
    let(:extra_setup) do
      tp    = create(:travel_plan, account: account)
      @dest = tp.flights.first.to
      raise unless @dest.name # sanity check
    end

    it do
      is_expected.to have_content \
        "Abroaders will help you earn the right points for your trip to #{@dest.name}"
    end
  end

  context "when I have already chosen an account type" do
    let(:extra_setup) do
      account.update_attributes!(onboarded_type: true)
    end

    it "doesn't allow access" do
      expect(current_path).not_to eq type_account_path
      expect(page).not_to have_button solo_btn
      expect(page).not_to have_button partner_btn
      expect(page).not_to have_field :partner_account_partner_first_name
    end
  end

  describe "clicking 'solo'" do
    let(:confirm_btn) { "Submit" }
    let(:click_confirm) { click_button confirm_btn }

    before { click_button solo_btn }

    it "hides the 'solo' button" do
      expect(page).not_to have_button solo_btn
    end

    it "asks me about my monthly spending" do
      expect(page).to have_field :solo_account_monthly_spending_usd
    end

    it "asks me about my eligibility to apply for cards" do
      is_expected.to have_field :solo_account_eligible_to_apply_true
      is_expected.to have_field :solo_account_eligible_to_apply_false
    end

    describe "clicking 'not eligible to apply'" do
      before { choose "No - I am not eligible" }

      it "hides the monthly spending input" do
        is_expected.not_to have_field :solo_account_monthly_spending_usd
      end

      describe "and clicking 'eligible to apply' again" do
        before { choose "Yes - I am eligible" }

        it "shows the monthly spending input again" do
          is_expected.to have_field :solo_account_monthly_spending_usd
        end
      end

      describe "and clicking 'submit'" do
        it "saves my information" do
          expect{click_confirm}.not_to change{Person.count}
          account.reload
          expect(account.monthly_spending_usd).to be_nil
          expect(me.reload).to be_ineligible_to_apply
        end

        it_marks_survey_as_complete
      end
    end

    describe "clicking 'Submit'" do
      describe "without adding a monthly spend" do
        it "doesn't save my info" do
          expect{click_confirm}.not_to change{Person.count}
          expect(account.reload.monthly_spending_usd).to be_nil
        end

        it "shows me the form again with an error message" do
          expect{click_confirm}.not_to change{current_path}
          is_expected.not_to have_button solo_btn
          is_expected.to have_field :solo_account_monthly_spending_usd
          is_expected.to have_field :solo_account_eligible_to_apply_true
          is_expected.to have_field :solo_account_eligible_to_apply_false
          is_expected.to have_button confirm_btn
        end

        it_doesnt_mark_survey_as_complete
      end

      describe "after adding a monthly spend" do
        before { fill_in :solo_account_monthly_spending_usd, with: 1000 }

        it "saves my information" do
          expect{click_confirm}.not_to change{Person.count}
          account.reload
          expect(account.monthly_spending_usd).to eq 1000
          expect(me).to be_eligible_to_apply
        end

        context "when I have said I am eligible to apply" do
          before { choose "Yes - I am eligible" }
          it "takes me to my spending survey page" do
            click_confirm
            expect(current_path).to eq new_person_spending_info_path(me)
          end
        end

        context "when I have said I am not eligible to apply" do
          before { choose "No - I am not eligible" }
          it "takes me to my balances survey" do
            click_confirm
            expect(current_path).to eq survey_person_balances_path(me)
          end

          it_marks_survey_as_complete
        end
      end
    end
  end

  describe "clicking 'partner'" do
    let(:confirm_btn) { "Submit" }
    let(:click_confirm) { click_button confirm_btn }

    # Don't use 'let'; we may want to click more than once!
    def click_partner; click_button partner_btn; end

    let(:partner_name) { "Steve" }

    before { click_partner }

    describe "without providing a name" do
      it "shows an error message" do
        expect(page).to have_error_message
      end

      it "doesn't show me the next step" do
        expect(page).to have_field :partner_account_partner_first_name
        expect(page).to have_button partner_btn
        expect(page).not_to have_field :partner_account_eligibility_both
        expect(page).not_to have_field :partner_account_eligibility_person_0
        expect(page).not_to have_field :partner_account_eligibility_person_1
        expect(page).not_to have_field :partner_account_eligibility_neither
        expect(page).not_to have_field :partner_account_monthly_spending_usd
      end

      describe "then providing a name and clicking again" do
        before do
          fill_in :partner_account_partner_first_name, with: partner_name
          click_partner
        end

        it "shows the next step and hides the error message" do
          expect(page).not_to have_field :partner_account_partner_first_name
          expect(page).not_to have_button partner_btn
          expect(page).to have_field :partner_account_eligibility_both
          expect(page).to have_field :partner_account_eligibility_person_0
          expect(page).to have_field :partner_account_eligibility_person_1
          expect(page).to have_field :partner_account_eligibility_neither
          expect(page).to have_field :partner_account_monthly_spending_usd
        end
      end
    end

    describe "after providing a name" do
      before do
        fill_in :partner_account_partner_first_name, with: partner_name
        click_partner
      end

      context "when the name has trailing whitespace" do
        let(:partner_name) { "    Steve    " }

        it "strips trailing whitespace" do
          expect(body).to have_content "Only Steve is eligible"
        end
      end

      it "shows me the next step" do
        expect(page).not_to have_field :partner_account_partner_first_name
        expect(page).not_to have_button partner_btn
        expect(page).to have_field :partner_account_eligibility_both
        expect(page).to have_field :partner_account_eligibility_person_0
        expect(page).to have_field :partner_account_eligibility_person_1
        expect(page).to have_field :partner_account_eligibility_neither
        expect(page).to have_field :partner_account_monthly_spending_usd
      end

      describe "selecting 'neither are eligible'" do
        before { choose :partner_account_eligibility_neither }

        it "hides the monthly spending input" do
          expect(page).not_to have_field :partner_account_monthly_spending_usd
        end

        describe "then selecting another option again" do
          before { choose :partner_account_eligibility_both }
          it "shows the monthly spending input again" do
            expect(page).to have_field :partner_account_monthly_spending_usd
          end
        end

        describe "then clicking 'submit'" do
          it "adds a partner to my account" do
            expect{click_confirm}.to change{account.people.count}.by(1)
            expect(account.people.last.first_name).to eq partner_name
          end

          it "marks me and my partner as ineligible to apply" do
            click_confirm
            expect(account.people.all?(&:ineligible_to_apply?)).to be true
          end

          it "takes me to my balances survey" do
            click_confirm
            expect(current_path).to eq survey_person_balances_path(me)
          end

          it_marks_survey_as_complete
        end
      end

      describe "saying that only one person is eligible to apply" do
        it "explains that only one person will receive recommendations" do
          choose :partner_account_eligibility_person_0
          expect(page).to have_content \
            "Only #{me.first_name} will receive credit card recommendations"
          choose :partner_account_eligibility_person_1
          expect(page).to have_content \
            "Only #{partner_name} will receive credit card recommendations"
        end

        describe "and clicking 'submit'" do
          before { choose :partner_account_eligibility_person_0 }

          context "adding monthly spending" do
            before { fill_in :partner_account_monthly_spending_usd, with: 1234 }

            it "adds a partner to my account" do
              expect{click_confirm}.to change{account.people.count}.by(1)
              expect(account.people.last.first_name).to eq partner_name
            end

            it "saves our monthly spending" do
              click_confirm
              expect(account.reload.monthly_spending_usd).to eq 1234
            end

            it "saves my partner's and my eligibility to apply" do
              click_confirm
              account.reload
              expect(account.people.find_by(main: true)).to be_eligible_to_apply
              expect(account.people.find_by(main: false)).to be_ineligible_to_apply
            end

            context "when I am the one eligible to apply" do
              it "takes me to the spending survey" do
                click_confirm
                expect(current_path).to eq new_person_spending_info_path(me)
              end
            end

            context "when my partner is the one eligible to apply" do
              before { choose :partner_account_eligibility_person_1 }
              it "takes me to my balances survey" do
                click_confirm
                expect(current_path).to eq survey_person_balances_path(me)
              end
            end

            it_marks_survey_as_complete
          end

          context "without adding monthly spending" do
            it "doesn't save any information" do
              expect{click_confirm}.not_to change{account.people.count}
              expect(account.reload.monthly_spending_usd).to be_nil
              expect(me.reload.onboarded_eligibility?).to be false
            end

            it "shows the form again with an error message" do
              expect(current_path).to eq type_account_path
            end

            it_doesnt_mark_survey_as_complete
          end
        end
      end

      describe "saying that we are both eligible to apply" do
        describe "and clicking 'submit'" do
          context "adding monthly spending" do
            before { fill_in :partner_account_monthly_spending_usd, with: 2345 }

            it "adds a partner to my account" do
              expect{click_confirm}.to change{account.people.count}.by(1)
              expect(account.people.last.first_name).to eq partner_name
            end

            it "saves our monthly spending" do
              click_confirm
              expect(account.reload.monthly_spending_usd).to eq 2345
            end

            it "saves my partner's and my eligibility to apply" do
              click_confirm
              expect(account.people[0]).to be_eligible_to_apply
              expect(account.people[1]).to be_eligible_to_apply
            end

            it "takes me to my spending survey" do
              click_confirm
              expect(current_path).to eq new_person_spending_info_path(me)
            end
          end

          context "without adding monthly spending" do
            it "doesn't save any information" do
              expect{click_confirm}.not_to change{account.people.count}
              expect(account.reload.monthly_spending_usd).to be_nil
              expect(me.reload.onboarded_eligibility?).to be false
            end

            it "shows the form again with an error message" do
              click_confirm
              expect(current_path).to eq type_account_path
              expect(page).to have_error_message
            end
          end
        end
      end
    end
  end
end
