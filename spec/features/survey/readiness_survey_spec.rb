require "rails_helper"

describe "as a new user", :js do
  subject { page }

  before do
    @account = create(:account, onboarding_stage: :readiness)
    @main_passenger = create(
      :main_passenger_with_spending,
      account:         @account,
      first_name:     "Steve"
    )
    if has_companion
      @companion = create(
        :companion_with_spending,
        account:         @account,
        first_name:      "Pete"
      )
    end

    login_as(@account)
    visit survey_readiness_path
  end
  let(:account)        { @account }
  let(:main_passenger) { @main_passenger }
  let(:companion)      { @companion }


  describe "the 'are you ready to apply?' survey page" do
    context "when I don't have a companion" do
      let(:has_companion) { false }

      it "asks me if 'You' are ready to apply" do
        is_expected.to have_content "Are you ready"
      end

      it "has radio buttons to say I'm ready or not ready" do
        is_expected.to have_field :readiness_survey_main_passenger_ready_true
        is_expected.to have_field :readiness_survey_main_passenger_ready_false
      end

      specify "'I'm ready' is selected by default" do
        radio = find("#readiness_survey_main_passenger_ready_true")
        expect(radio).to be_checked
      end

      describe "submitting the form" do
        before { click_button "Confirm" }

        it "marks me as ready to apply" do
          main_passenger.reload
          expect(main_passenger.readiness_status_given?).to be_truthy
          expect(main_passenger).to be_ready_to_apply
        end

        it "marks my account as onboarded" do
          expect(account.reload).to be_onboarded
        end

        it "takes me to my dashboard"
      end

      describe "selecting 'I'm not ready'" do
        before { choose :readiness_survey_main_passenger_ready_false }

        def unreadiness_reason_field
          :readiness_survey_main_passenger_unreadiness_reason
        end

        it "shows a text field asking why I'm not ready" do
          is_expected.to have_field unreadiness_reason_field
        end

        describe "typing a reason into the text field" do
          let(:reason) { "Because I said so, bitch!" }
          before { fill_in unreadiness_reason_field, with: reason }

          describe "and clicking 'confirm'" do
            before { click_button "Confirm" }

            it "marks my account as onboarded" do
              expect(account.reload).to be_onboarded
            end

            it "saves my status as 'not ready to reply'" do
              main_passenger.reload
              expect(main_passenger.readiness_status_given?).to be_truthy
              expect(main_passenger).to be_unready_to_apply
            end

            it "takes me to my dashboard"
          end
        end

        describe "and clicking 'cancel'" do
          before { choose :readiness_survey_main_passenger_ready_true }

          describe "and clicking 'not ready' again" do
            before { choose :readiness_survey_main_passenger_ready_false }

            specify "the 'reason' text box is blank again" do
              field = find("##{unreadiness_reason_field}")
              expect(field.value).to be_blank
            end
          end
        end

        describe "clicking 'confirm' without providing a reason" do
          before { click_button "Confirm" }

          it "saves my status as 'not ready to reply'" do
            main_passenger.reload
            expect(main_passenger.readiness_status_given?).to be_truthy
            expect(main_passenger).to be_unready_to_apply
            expect(main_passenger.unreadiness_reason).to be_blank
          end

          it "marks my account as onboarded" do
            expect(account.reload).to be_onboarded
          end

          it "queues a reminder email"
          it "takes me to my dashboard"
        end
      end
    end # when I don't have a companion

    context "when I have a companion" do
      let(:has_companion) { true }

      it "asks me if (My name) is ready to apply" do
        is_expected.to have_content "Is Steve ready"
      end

      it "asks me if (Companion's name) is ready to apply" do
        is_expected.to have_content "Is Pete ready"
      end

      it "has radios to say I and my companion are ready or not ready" do
        is_expected.to have_field :readiness_survey_main_passenger_ready_true
        is_expected.to have_field :readiness_survey_main_passenger_ready_false
        is_expected.to have_field :readiness_survey_companion_ready_true
        is_expected.to have_field :readiness_survey_companion_ready_false
      end

      describe "saying that I'm ready" do
        describe "and saying my companion is ready" do
          before { click_button "Confirm" }

          it "saves both of our statuses as 'ready'" do
            main_passenger.reload
            companion.reload
            expect(main_passenger.readiness_status_given?).to be_truthy
            expect(main_passenger).to be_ready_to_apply
            expect(companion.readiness_status_given?).to be_truthy
            expect(companion).to be_ready_to_apply
          end

          it "marks my account as onboarded" do
            expect(account.reload).to be_onboarded
          end

          it "takes me to my dashboard"
        end

        describe "and saying my companion is not ready" do
          before do
            choose :readiness_survey_companion_ready_false
            click_button "Confirm"
          end

          it "saves both of our statuses" do
            main_passenger.reload
            companion.reload
            expect(main_passenger.readiness_status_given?).to be_truthy
            expect(main_passenger).to be_ready_to_apply
            expect(companion.readiness_status_given?).to be_truthy
            expect(companion).to be_unready_to_apply
          end

          it "marks my account as onboarded" do
            expect(account.reload).to be_onboarded
          end

          it "queues a reminder email"

          it "takes me to my dashboard"
        end
      end


      describe "saying that I'm not ready" do
        before { choose :readiness_survey_main_passenger_ready_false }

        describe "and saying my companion is ready" do
          before { click_button "Confirm" }

          it "saves both of our statuses" do
            main_passenger.reload
            companion.reload
            expect(main_passenger.readiness_status_given?).to be_truthy
            expect(main_passenger).to be_unready_to_apply
            expect(companion.readiness_status_given?).to be_truthy
            expect(companion).to be_ready_to_apply
          end

          it "marks my account as onboarded" do
            expect(account.reload).to be_onboarded
          end

          it "takes me to my dashboard"
        end

        describe "and saying my companion is not ready" do
          before do
            choose :readiness_survey_companion_ready_false
            click_button "Confirm"
          end

          it "saves both of our statuses as 'not ready'" do
            main_passenger.reload
            companion.reload
            expect(main_passenger.readiness_status_given?).to be_truthy
            expect(main_passenger).to be_unready_to_apply
            expect(companion.readiness_status_given?).to be_truthy
            expect(companion).to be_unready_to_apply
          end

          it "marks my account as onboarded" do
            expect(account.reload).to be_onboarded
          end

          it "queues reminder emails"

          it "takes me to my dashboard"
        end
      end
    end # when I have a companion
  end
end
