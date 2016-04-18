require "rails_helper"

describe "account type select page", :onboarding do
  subject { page }

  let!(:account) { create(:account) }
  let!(:me) { account.people.first }

  before do
    login_as_account(account)
    visit type_account_path
  end

  let(:partner_btn) { t("accounts.type.sign_up_for_couples_earning") }
  let(:solo_btn)    { t("accounts.type.sign_up_for_solo_earning") }

  it "gives me the option to choose a 'Solo' or 'Partner' account" do
    is_expected.to have_button solo_btn
    is_expected.to have_button partner_btn
    is_expected.to have_field :partner_account_partner_first_name
  end

  describe "clicking 'solo'", :js do
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
      before { choose :solo_account_eligible_to_apply_false }

      it "hides the monthly spending input" do
        is_expected.not_to have_field :solo_account_monthly_spending_usd
      end

      describe "and clicking 'eligible to apply' again" do
        before { choose :solo_account_eligible_to_apply_true }

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

        it "takes me to the spending survey" do
          click_confirm
          expect(current_path).to eq new_person_spending_info_path(me)
        end
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
      end

      describe "after adding a monthly spend" do
        before { fill_in :solo_account_monthly_spending_usd, with: 1000 }

        it "saves my information" do
          expect{click_confirm}.not_to change{Person.count}
          account.reload
          expect(account.monthly_spending_usd).to eq 1000
          expect(me).to be_eligible_to_apply
        end

        it "takes me to the spending survey page" do
          click_confirm
          expect(current_path).to eq new_person_spending_info_path(me)
        end
      end
    end
  end

  describe "clicking 'partner'", :js do
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
          expect(body).to have_selector \
            ".partner_account_person_1_first_name",
            text: /\ASteve\z/
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

            it "takes me to the spending survey" do
              click_confirm
              expect(current_path).to eq new_person_spending_info_path(me)
            end
          end

          context "without adding monthly spending" do
            it "doesn't save any information" do
              expect{click_confirm}.not_to change{account.people.count}
              expect(account.reload.monthly_spending_usd).to be_nil
              expect(me.reload.eligibility_given?).to be false
            end

            it "shows the form again with an error message" do
              expect(current_path).to eq type_account_path
            end
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

            it "takes me to the spending survey" do
              click_confirm
              expect(current_path).to eq new_person_spending_info_path(me)
            end
          end

          context "without adding monthly spending" do
            it "doesn't save any information" do
              expect{click_confirm}.not_to change{account.people.count}
              expect(account.reload.monthly_spending_usd).to be_nil
              expect(me.reload.eligibility_given?).to be false
            end

            it "shows the form again with an error message" do
              expect(current_path).to eq type_account_path
            end
          end
        end
      end
    end
  end
end
