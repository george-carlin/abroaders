require "rails_helper"

describe "survey_readiness page", :onboarding, :js do
  before { skip 'tests need updating' }
  def visit_survey_readiness_path(account)
    login_as(account)
    visit survey_readiness_path
  end

  def choose_radio(text)
    find(:radio_button, text).trigger("click")
  end

  include_context "set admin email ENV var"

  let(:submit_form) { click_button "Save and continue" }

  describe "account with companion" do
    before do
      @account = create(:account, :with_companion)
      login_as(@account)
    end

    context "when owner is ineligible" do
      before do
        @account.owner.update!(eligible: false)
        visit survey_readiness_path
      end

      example "initial layout" do
        expect(page).to have_no_field("readiness_survey_who_both")
        expect(page).to have_no_field("readiness_survey_who_owner")
        expect(page).to have_field("readiness_survey_who_companion")
        expect(page).to have_field("readiness_survey_who_neither")

        expect(find(:css, "#readiness_survey_who_companion")).to be_checked
      end

      context "and choose companion is ready" do
        before { choose_radio("readiness_survey_who_companion") }

        it "updates companion status" do
          submit_form
          @account.reload
          expect(@account.owner).not_to be_ready
          expect(@account.companion).to be_ready
        end

        skip "tracking intercom events for unready owner and ready for companion", :intercom do
          expect { submit_form }.to \
            track_intercom_event("obs_unready_own", "obs_ready_com").for_email(@account.email)
        end
      end
    end

    context "when companion is ineligible" do
      before do
        @account.companion.update!(eligible: false)
        visit survey_readiness_path
      end

      example "initial layout" do
        expect(page).to have_no_field("readiness_survey_who_both")
        expect(page).to have_field("readiness_survey_who_owner")
        expect(page).to have_no_field("readiness_survey_who_companion")
        expect(page).to have_field("readiness_survey_who_neither")

        expect(find(:css, "#readiness_survey_who_owner")).to be_checked
      end

      context "and choose owner is ready" do
        before { choose_radio("readiness_survey_who_owner") }

        it "updates owner status" do
          submit_form
          @account.reload
          expect(@account.companion).not_to be_ready
          expect(@account.owner).to be_ready
        end

        skip "tracking intercom events for unready companion and ready for owner", :intercom do
          expect { submit_form }.to \
            track_intercom_event("obs_ready_own", "obs_unready_com").for_email(@account.email)
        end
      end
    end

    context "when both people are eligible" do
      before { visit survey_readiness_path }

      example "initial layout" do
        visit survey_readiness_path
        expect(page).to have_field("readiness_survey_who_both")
        expect(page).to have_field("readiness_survey_who_owner")
        expect(page).to have_field("readiness_survey_who_companion")
        expect(page).to have_field("readiness_survey_who_neither")

        expect(find(:css, "#readiness_survey_who_both")).to be_checked
      end

      context "and choose both are ready" do
        before { choose_radio("readiness_survey_who_both") }

        example "updating people statuses" do
          submit_form
          @account.reload
          expect(@account.owner).to be_ready
          expect(@account.companion).to be_ready
          expect(current_path).to eq root_path
        end

        skip "tracking intercom events for owner and companion", :intercom do
          expect { submit_form }.to \
            track_intercom_events("obs_ready_own", "obs_ready_com").for_email(@account.email)
        end
      end

      context "and choose only owner is ready" do
        before { choose_radio("readiness_survey_who_owner") }

        it "updates owner status" do
          submit_form
          @account.reload
          expect(@account.companion).not_to be_ready
          expect(@account.owner).to be_ready
        end

        skip "tracking ready intercom event for owner and unready for companion", :intercom do
          expect { submit_form }.to \
            track_intercom_events("obs_ready_own", "obs_unready_com").for_email(@account.email)
        end
      end

      context "and choose only companion is ready" do
        before { choose_radio("readiness_survey_who_companion") }

        it "updates companion status" do
          submit_form
          @account.reload
          expect(@account.owner).not_to be_ready
          expect(@account.companion).to be_ready
        end

        skip "tracking ready intercom event for companion and ready for owner", :intercom do
          expect { submit_form }.to \
            track_intercom_events("obs_unready_own", "obs_ready_com").for_email(@account.email)
        end
      end

      context "and choose neither are ready" do
        before { choose_radio("readiness_survey_who_neither") }

        it "doesn't update people statuses" do
          submit_form
          @account.reload
          expect(@account.owner).not_to be_ready
          expect(@account.companion).not_to be_ready
        end

        skip "tracking unready intercom events for companion for owner", :intercom do
          expect { submit_form }.to \
            track_intercom_events("obs_unready_own", "obs_unready_com").for_email(@account.email)
        end
      end
    end
  end

  describe "account without companion" do
    before do
      @account = create(:account, onboarding_state: "readiness")
      login_as(@account)
      visit survey_readiness_path
    end

    example "initial layout" do
      expect(page).to have_field("readiness_survey_who_owner")
      expect(page).to have_field("readiness_survey_who_neither")
      expect(page).to have_no_field("readiness_survey_who_both")
      expect(page).to have_no_field("readiness_survey_who_companion")

      expect(find(:css, "#readiness_survey_who_owner")).to be_checked
    end

    context "and choose I am ready" do
      before { choose_radio("readiness_survey_who_owner") }

      it "updates owner status" do
        submit_form
        @account.reload
        expect(@account.owner).to be_ready
      end

      skip "tracking ready intercom event for owner", :intercom do
        expect { submit_form }.to \
          track_intercom_events("obs_ready_own").for_email(@account.email)
      end
    end

    context "and choose I am not ready" do
      before { choose_radio("readiness_survey_who_neither") }

      it "doesn't update owner status" do
        submit_form
        @account.reload
        expect(@account.owner).not_to be_ready
      end

      skip "tracking unready intercom event for owner", :intercom do
        expect { submit_form }.to \
          track_intercom_events("obs_unready_own").for_email(@account.email)
      end
    end
  end

  example "unreadiness reasons saving" do
    account = create(:account, :with_companion, onboarding_state: "readiness")
    login_as(account)
    visit survey_readiness_path

    choose_radio "readiness_survey_who_neither"
    fill_in("readiness_survey_owner_unreadiness_reason", with: "reason 1")
    fill_in("readiness_survey_companion_unreadiness_reason", with: "reason 2")

    submit_form

    account.reload
    expect(account.owner.unreadiness_reason).to eq("reason 1")
    expect(account.companion.unreadiness_reason).to eq("reason 2")
  end

  example "ineligible accounts skip this page" do
    account = create(:account, :with_companion, onboarding_state: "readiness")
    login_as(account)
    account.owner.update!(eligible: false)
    account.companion.update!(eligible: false)

    visit survey_readiness_path
    expect(current_path).to eq root_path
  end

  example "hiding and showing unreadiness reason field", :js do
    account = create(:account, :with_companion, onboarding_state: "readiness")
    login_as(account)
    visit survey_readiness_path

    choose_radio "readiness_survey_who_neither"
    expect(page).to have_field "readiness_survey_owner_unreadiness_reason"
    expect(page).to have_field "readiness_survey_companion_unreadiness_reason"
    choose_radio "readiness_survey_who_both"
    expect(page).to have_no_field "readiness_survey_owner_unreadiness_reason"
    expect(page).to have_no_field "readiness_survey_companion_unreadiness_reason"
  end
end
