require "rails_helper"

describe "the spending info survey", :onboarding do
  subject { page }

  include ActiveJob::TestHelper

  let!(:account) do
    create(:account, onboarded_travel_plans: true, onboarded_type: true)
  end

  before do
    @me = if i_am_owner
            account.owner
          else
            account.owner.update_attributes!(onboarded_balances: true)
            create(:person, main: false, account: account)
            account.companion
          end
    me.update_attributes!(eligible: true)
    login_as(account, scope: :account)
    visit new_person_spending_info_path(me)
  end

  let(:me) { @me }

  let(:i_am_owner) { true }

  let(:submit_form) { click_button "Save" }

  it { is_expected.to have_no_sidebar }

  it "asks me for my financial info" do
    expect(page).to have_field :spending_info_credit_score
    expect(page).to have_field :spending_info_will_apply_for_loan_true
    expect(page).to have_field :spending_info_will_apply_for_loan_false
    expect(page).to have_field :spending_info_has_business_with_ein
    expect(page).to have_field :spending_info_has_business_without_ein
    expect(page).to have_field :spending_info_has_business_no_business
  end

  describe "'I have a business'" do
    it "is 'no' by default" do
      # "No" radio is checked
      radio = find("#spending_info_has_business_no_business")
      expect(radio).to be_checked
      # business spending input is not possible
      expect(page).to have_no_field :spending_info_business_spending_usd
    end

    {
      'with_ein' => 'with EIN', 'without_ein' => 'without EIN'
    }.each do |key, human|
      describe "selecting 'I have a business #{human}'", :js do
        before { choose "spending_info_has_business_#{key}" }

        it "shows my 'business spending' input" do
          expect(page).to have_field :spending_info_business_spending_usd
        end

        describe "and typing a value into 'business spending'" do
          before { fill_in :spending_info_business_spending_usd, with: 1234 }
          describe "and selecting 'I don't have a business' again" do
            before { choose :spending_info_has_business_no_business }
            describe "and submitting the form with valid data" do
              before do
                fill_in :spending_info_credit_score, with: 456
                submit_form
              end

              it "doesn't save what I'd typed for 'business spending'" do
                expect(me.reload.business_spending_usd).to be_blank
              end
            end
          end
        end

        describe "and selecting 'I don't have a business' again" do
          before { choose :spending_info_has_business_no_business }
          it "hides the 'business spending' input again" do
            expect(page).to have_no_field :spending_info_business_spending_usd
          end
        end

        context "and submitting the form with invalid data" do
          before { submit_form }
          it "remembers my previous selection for 'I have a business'" do
            expect(find("#spending_info_has_business_#{key}")).to be_checked
            expect(page).to have_field :spending_info_business_spending_usd
          end
        end
      end
    end
  end # 'I have a business'

  describe "submitting the form", :js do
    describe "with valid information" do
      before do
        fill_in :spending_info_credit_score, with: 456
        choose  :spending_info_will_apply_for_loan_true
      end

      let(:new_info) { me.reload.spending_info }

      context "saying I don't have a business" do
        it "saves information about my spending" do
          expect{submit_form}.to change{SpendingInfo.count}.by(1)

          expect(new_info).to be_persisted
          expect(new_info.credit_score).to eq 456
          expect(new_info.will_apply_for_loan).to be_truthy
          expect(new_info.has_business).to eq "no_business"
        end
      end

      context "saying I do have a business" do
        before do
          choose  :spending_info_has_business_without_ein
          fill_in :spending_info_business_spending_usd, with: 5000
        end

        it "saves information about my spending" do
          expect{submit_form}.to change{SpendingInfo.count}.by(1)

          expect(new_info).to be_persisted
          expect(new_info.credit_score).to eq 456
          expect(new_info.will_apply_for_loan).to be_truthy
          expect(new_info.has_business).to eq "without_ein"
          expect(new_info.business_spending_usd).to eq 5000
        end
      end

      it "takes me to my card survey page" do
        submit_form
        expect(current_path).to eq survey_person_card_accounts_path(me)
      end

      context "when I am the account owner" do
        let(:i_am_owner) { true }
        it "tracks an event on Intercom", :intercom do
          expect{submit_form}.to \
            track_intercom_event("obs_spending_own").
            for_email(account.email)
        end
      end

      context "when I am the companion" do
        let(:i_am_owner) { false }
        it "tracks an event on Intercom", :intercom do
          expect{submit_form}.to \
            track_intercom_event("obs_spending_com").
            for_email(account.email)
        end
      end
    end

    describe "with invalid information" do
      it "doesn't save any spending info" do
        expect{submit_form}.not_to change{SpendingInfo.count}
      end

      it "shows the form again with an error message" do
        submit_form
        expect(page).to have_selector "form#new_spending_info"
        expect(page).to have_error_message
      end

      it "doesn't give redundant error messages for credit score" do
        submit_form
        # Bug fix: previously it was giving me both "can't be blank" and "not a
        # number"
        within ".alert.alert-danger" do
          expect(page).to have_content "Credit score can't be blank"
          expect(page).to have_no_content "Credit score is not a number"
        end
      end

      it "doesn't lose what I'd previously selected for 'will apply for loan'" do
        # Bug fix
        yes = find("#spending_info_will_apply_for_loan_false")
        expect(yes).to be_checked
        submit_form
        yes.reload
        expect(yes).to be_checked
        submit_form
        choose :spending_info_will_apply_for_loan_true
        submit_form
        no = find("#spending_info_will_apply_for_loan_true")
        expect(no).to be_checked
      end
    end

    describe "with an invalid value for 'business spending'" do
      before do
        choose :spending_info_has_business_with_ein
        submit_form
      end

      it "displays a human-friendly error message" do # bug fix
        within ".alert.alert-danger" do
          expect(page).to have_content "Business spending can't be blank"
        end
      end
    end
  end
end
