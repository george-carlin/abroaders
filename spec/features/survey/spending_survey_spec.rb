require "rails_helper"

describe "the spending info survey" do
  let(:account) do
    create(
      :account,
      shares_expenses: shares_expenses,
      onboarding_stage: "spending"
    )
  end
  before do
    create(:main_passenger, account: account)
    if has_companion
      create(:passenger, :companion, account: account)
    end
    login_as account, scope: :account
    visit survey_spending_path
  end
  subject { page }

  DEFAULT_SPENDING_FIELDS = %i[
    credit_score
    will_apply_for_loan_true
    will_apply_for_loan_false
    has_business_with_ein
    has_business_without_ein
    has_business_no_business
  ]

  let(:ps_prefix) { "spending_survey" }
  let(:mp_prefix) { "#{ps_prefix}_main_passenger" }
  let(:co_prefix) { "#{ps_prefix}_companion" }

  let(:shares_expenses) { false }

  let(:submit_form) { click_button "Save" }

  shared_examples "business spending input" do |opts={}|
    my        = opts[:companion] ? "my companion's"   : "my"
    i_have    = opts[:companion] ? "my companion has" : "I have"
    dont_have = opts[:companion] ? "my companion doesn't have" : "I don't have"

    let(:prefix) { opts[:companion] ? co_prefix : mp_prefix }

    it "'#{dont_have.capitalize} a business' is selected by default" do
      radio = find("##{prefix}_has_business_no_business")
      expect(radio).to be_checked
      expect(radio[:checked]).to be_truthy
    end

    it "does not have a field for #{my} business spending" do
      is_expected.to have_no_field "#{prefix}_business_spending"
    end

    {
      'with_ein' => 'with EIN', 'without_ein' => 'without EIN'
    }.each do |key, human|
      describe "selecting '#{i_have} a business #{human}'", :js do
        before { choose "#{prefix}_has_business_#{key}" }

        it "shows #{my} 'business spending' input" do
          is_expected.to have_field "#{prefix}_business_spending"
        end

        describe "and typing a value into 'business spending'" do
          before { fill_in "#{prefix}_business_spending", with: 1234 }
          describe "and selecting '#{dont_have} a business' again" do
            before { choose "#{prefix}_has_business_no_business" }
            describe "and submitting the form with valid data" do
              before do
                fill_in_valid_main_passenger_spending_info
                if has_companion
                  fill_in "#{co_prefix}_credit_score", with: 654
                  fill_in "#{co_prefix}_personal_spending", with: 8000
                end
                submit_form
              end

              it "doesn't save what I'd typed for 'business spending'" do
                account.reload
                if opts[:companion]
                  expect(account.companion.business_spending).to be_blank
                else
                  expect(account.main_passenger.business_spending).to be_blank
                end
              end
            end
          end
        end

        describe "and selecting '#{dont_have} a business' again" do
          before { choose "#{prefix}_has_business_no_business" }
          it "hides the 'business spending' input again" do
            is_expected.to have_no_field "#{prefix}_business_spending"
          end
        end

        context "and submitting the form with invalid data" do
          before { submit_form }
          it "remembers my previous selection for 'I have a business'" do
            expect(find("##{prefix}_has_business_#{key}")).to be_checked
            expect(page).to have_field "#{prefix}_business_spending"
          end
        end
      end
    end
  end

  shared_examples "with invalid information" do
    describe "with invalid information" do
      it "doesn't save any spending info" do
        expect{submit_form}.not_to change{SpendingInfo.count}
      end

      it "doesn't change my 'onboarding stage'" do
        expect{submit_form}.not_to change{account.reload.onboarding_stage}
      end

      it "shows the form again with an error message" do
        expect{submit_form}.not_to change{current_path}
        expect(page).to have_error_message
      end
    end
  end

  def fill_in_valid_main_passenger_spending_info
    fill_in "#{mp_prefix}_credit_score", with: 456
    fill_in "#{mp_prefix}_personal_spending", with: 6789
    choose  "#{mp_prefix}_will_apply_for_loan_true"
  end

  describe "when I don't have a travel companion" do
    let(:has_companion) { false }

    it "asks me for my spending info" do
      DEFAULT_SPENDING_FIELDS.each do |field|
        is_expected.to have_field "#{mp_prefix}_#{field}"
      end
    end

    it "doesn't ask anything about a travel companion" do
      DEFAULT_SPENDING_FIELDS.each do |field|
        is_expected.to have_no_field "#{co_prefix}_#{field}"
      end
    end

    include_examples "business spending input"

    describe "submitting the form", :js do
      describe "with valid information" do
        before { fill_in_valid_main_passenger_spending_info }

        context "saying I don't have a business" do
          it "saves information about my spending" do
            expect{submit_form}.to change{SpendingInfo.count}.by(1)

            account.reload

            info = account.main_passenger.spending_info
            expect(info).to be_persisted
            expect(info.credit_score).to eq 456
            expect(info.will_apply_for_loan).to be_truthy
            expect(info.personal_spending).to eq 6789
          end

          it "takes me to the card accounts survey" do
            submit_form
            expect(current_path).to eq survey_card_accounts_path(:main)
          end
        end

        context "saying I do have a business" do
          before do
            choose  "#{mp_prefix}_has_business_without_ein"
            fill_in "#{mp_prefix}_business_spending", with: 5000
          end

          it "saves information about my spending" do
            expect{submit_form}.to change{SpendingInfo.count}.by(1)

            account.reload

            info = account.main_passenger.spending_info
            expect(info).to be_persisted
            expect(info.credit_score).to eq 456
            expect(info.will_apply_for_loan).to be_truthy
            expect(info.personal_spending).to eq 6789
            expect(info.has_business).to eq "without_ein"
            expect(info.business_spending).to eq 5000
          end

          it "takes me to the card accounts survey" do
            submit_form
            expect(current_path).to eq survey_card_accounts_path(:main)
          end
        end

        it "marks my 'onboarding stage' as 'main passenger cards'" do
          submit_form
          expect(account.reload.onboarding_stage).to eq "main_passenger_cards"
        end
      end

      include_examples "with invalid information"

      describe "when I try to save a blank credit score" do
        before { submit_form }
        it "only gives me one error message" do
          # Bug fix: previously it was giving me both "can't be blank"
          # and "not a number"
          within ".alert.alert-danger" do
            is_expected.to have_content "Credit score can't be blank"
            is_expected.not_to have_content "Credit score is not a number"
          end
        end
      end

      context "after an invalid submission" do
        context "the error message" do
          before { submit_form }

          it { is_expected.to have_content "your info could not be saved" }

          it "doesn't mention 'main passenger' or 'companion'" do
            within ".alert.alert-danger" do
              is_expected.not_to have_content "Main passenger"
              is_expected.not_to have_content "Companion"
              is_expected.to have_content "Credit score can't be blank"
            end
          end
        end

        it "remembers what I had selected for 'will apply for loan'" do
          # Bug fix
          yes = find("##{mp_prefix}_will_apply_for_loan_false")
          expect(yes).to be_checked
          submit_form
          yes.reload
          expect(yes).to be_checked
          submit_form
          choose "#{mp_prefix}_will_apply_for_loan_true"
          submit_form
          no = find("##{mp_prefix}_will_apply_for_loan_true")
          expect(no).to be_checked
        end
      end
    end
  end # when I don't have a travel companion

  describe "when I have a travel companion" do
    let(:has_companion) { true }

    it "asks for my and my companion's spending info" do
      DEFAULT_SPENDING_FIELDS.each do |field|
        is_expected.to have_field "#{mp_prefix}_#{field}"
        is_expected.to have_field "#{co_prefix}_#{field}"
      end
    end

    describe "and we share expenses" do
      let(:shares_expenses) { true }

      it "has a single input for our shared personal spending" do
        is_expected.to have_field "#{ps_prefix}_shared_spending"
        is_expected.to have_no_field "#{mp_prefix}_personal_spending"
        is_expected.to have_no_field "#{co_prefix}_personal_spending"
      end

      describe "submitting the form" do
        before do
          fill_in "#{mp_prefix}_credit_score", with: 456
          choose  "#{mp_prefix}_will_apply_for_loan_true"
          fill_in "#{co_prefix}_credit_score", with: 654
        end

        describe "with valid information" do
          before do
            fill_in "#{ps_prefix}_shared_spending", with: 6789
            submit_form
          end

          it "saves the shared spending info" do
            expect(account.reload.shared_spending).to eq 6789
          end
        end

        describe "leaving the shared spending blank" do
          it "doesn't save, and shows the form again with an error message" do
            expect{submit_form}.not_to change{SpendingInfo.count}
            expect(current_path).to eq survey_spending_path
            expect(page).to have_error_message
          end
        end
      end
    end

    describe "and we don't share expenses" do
      let(:shares_expenses) { false }

      it "has two inputs, one for each of our personal spending" do
        is_expected.to have_no_field :shared_spending
        is_expected.to have_field "#{mp_prefix}_personal_spending"
        is_expected.to have_field "#{co_prefix}_personal_spending"
      end
    end

    include_examples "business spending input"
    include_examples "business spending input", companion: true

    describe "submitting the form", :js do
      describe "with valid information about my and my partner's spending" do
        before do
          fill_in_valid_main_passenger_spending_info
          fill_in "#{co_prefix}_credit_score", with: 654
          fill_in "#{co_prefix}_personal_spending", with: 8000
          choose  "#{co_prefix}_has_business_with_ein"
          fill_in "#{co_prefix}_business_spending", with: 4500
        end

        it "saves the spending information" do
          expect{submit_form}.to change{SpendingInfo.count}.by(2)

          account.reload

          main_info = account.main_passenger.spending_info
          expect(main_info).to be_persisted
          expect(main_info.credit_score).to eq 456
          expect(main_info.will_apply_for_loan).to be_truthy
          expect(main_info.has_business).to eq "no_business"
          expect(main_info.personal_spending).to eq 6789

          companion_info = account.companion.spending_info
          expect(companion_info).to be_persisted
          expect(companion_info.credit_score).to eq 654
          expect(companion_info.will_apply_for_loan).to be_falsey
          expect(companion_info.has_business).to eq "with_ein"
          expect(companion_info.personal_spending).to eq 8000
          expect(companion_info.business_spending).to eq 4500
        end

        it "takes me to the card accounts survey" do
          submit_form
          expect(current_path).to eq survey_card_accounts_path(:main)
        end

        it "marks my 'onboarding stage' as 'main passenger cards'" do
          submit_form
          expect(account.reload.onboarding_stage).to eq "main_passenger_cards"
        end
      end

      include_examples "with invalid information"
    end
  end
end
