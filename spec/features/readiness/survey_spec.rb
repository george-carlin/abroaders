require "rails_helper"

describe "readiness status pages", :js, :onboarding do
  subject { page }

  include_context "set erik's email ENV var"

  let!(:account) do
    create(
      :account,
      onboarded_travel_plans:   onboarded_travel_plans,
      onboarded_type:           onboarded_type,
    )
  end

  before do
    if i_am_owner
      @me = account.owner
    else
      @me = create(:person, owner: false, account: account)
    end

    i_am_eligible ? me.eligible_to_apply! : me.ineligible_to_apply!

    if i_am_already_ready
      me.ready_to_apply!
    end

    login_as(account.reload)
  end

  let(:me) { @me }

  let(:i_am_owner)         { true }
  let(:i_am_eligible)      { true }
  let(:i_am_already_ready) { false }

  let(:onboarded_travel_plans) { true }
  let(:onboarded_type) { true }


  describe "new page" do
    before { visit new_person_readiness_status_path(me) }

    let(:submit_form) { click_button "Confirm" }

    shared_examples "track intercom event" do |ready|
      event_name = "#{"un" unless ready}ready"

      context "when I am the account owner", :intercom do
        let(:i_am_owner) { true }
        it "tracks an event on Intercom" do
          expect{submit_form}.to \
            track_intercom_event("obs_#{event_name}_own").for_email(account.email)
        end
      end

      context "when I am the companion", :intercom do
        let(:i_am_owner) { false }
        it "tracks an event on Intercom" do
          expect{submit_form}.to \
            track_intercom_event("obs_#{event_name}_com").for_email(account.email)
        end
      end
    end

    context "when I've already said I'm ready" do
      let(:i_am_already_ready) { true }
      it "redirects to the dashboard" do
        expect(current_path).to eq root_path
      end
    end

    context "when I'm not eligible to apply for cards" do
      let(:i_am_eligible) { false }
      it "redirects to the dashboard" do
        expect(current_path).to eq root_path
      end
    end

    context "when I haven't completed the travel plans survey" do
      let(:onboarded_travel_plans) { false }
      it "redirects me to the travel plan survey" do
        expect(current_path).to eq new_travel_plan_path
      end
    end

    context "when I haven't chosen an account type yet" do
      let(:onboarded_type) { false }
      it "redirects me to the accounts type survey" do
        expect(current_path).to eq type_account_path
      end
    end

    it "has radio buttons to say I'm ready or not ready" do
      is_expected.to have_field :readiness_status_ready_true
      is_expected.to have_field :readiness_status_ready_false
    end

    it "doesn't show the sidebar" do
      is_expected.to have_no_selector "#menu"
    end

    pending "it shows the sidebar if I'm onboarded but previously said I wasn't ready"

    specify "'I'm ready' is selected by default" do
      expect(find("#readiness_status_ready_true")).to be_checked
    end

    describe "submitting the form" do
      it "marks me as ready to apply" do
        submit_form
        me.reload
        expect(me.readiness_given?).to be_truthy
        expect(me).to be_ready_to_apply
      end

      include_examples "track intercom event", true
    end

    describe "selecting 'I'm not ready'" do
      before { choose :readiness_status_ready_false }

      def unreadiness_reason_field
        :readiness_status_unreadiness_reason
      end

      it "shows a text field asking why I'm not ready" do
        is_expected.to have_field unreadiness_reason_field
      end

      describe "typing a reason into the text field" do
        let(:reason) { "Because I said so, bitch!" }
        before { fill_in unreadiness_reason_field, with: reason }

        describe "and clicking 'confirm'" do
          it "saves my status as 'not ready to reply'" do
            submit_form
            me.reload
            expect(me.readiness_given?).to be_truthy
            expect(me).to be_unready_to_apply
          end
        end

        include_examples "track intercom event", false
      end

      describe "and clicking 'cancel'" do
        before { choose :readiness_status_ready_true }

        describe "and clicking 'not ready' again" do
          before { choose :readiness_status_ready_false }

          specify "the 'reason' text box is blank again" do
            field = find("##{unreadiness_reason_field}")
            expect(field.value).to be_blank
          end
        end
      end

      describe "clicking 'confirm' without providing a reason" do
        it "saves my status as 'not ready to reply'" do
          submit_form
          me.reload
          expect(me.readiness_given?).to be_truthy
          expect(me).to be_unready_to_apply
          expect(me.unreadiness_reason).to be_blank
        end

        it "queues a reminder email"

        include_examples "track intercom event", false
      end
    end

    describe "after submit" do
      before do
        if i_am_eligible_to_apply
          me.eligible_to_apply!
        end

        if i_am_the_partner
          me.update_attributes!(main: false)
          Person.create!(account: account, main: true, first_name: "X")
        elsif i_have_a_partner
          @partner = account.create_companion!(first_name: "Somebody")
          if partner_is_eligible_to_apply
            @partner.eligible_to_apply!
          end
        end
      end

      let(:i_am_eligible_to_apply) { false }
      let(:i_am_the_partner) { false }
      let(:i_have_a_partner) { false }
      let(:partner) { @partner }

      context "when I am the main person on the account" do
        let(:i_am_the_partner) { false }

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

      context "when I am the partner on the account" do
        let(:i_am_the_partner) { true }
        it "takes me to the dashboard" do
          submit_form
          expect(current_path).to eq root_path
        end

        include_examples "send survey complete email to admin"
      end
    end
  end

  describe "edit page" do
    before do
      if i_have_said_im_not_ready
        me.unready_to_apply!(reason: reason)
      end

      visit person_readiness_status_path(me)
    end

    let(:i_have_said_im_not_ready) { false }
    let(:reason) { nil }

    describe "explicitly unready person" do
      let(:i_have_said_im_not_ready)  { true }
      let(:reason) { "meow" }
      it "sees readiness date and readiness_reason" do
        expect(page).to have_content me.readiness_status.unreadiness_reason
        expect(page).to have_content me.readiness_status.created_at.strftime("%D")
      end
    end

    describe "unready person clicks ready button" do
      let(:i_have_said_im_not_ready)  { true }
      let(:submit_form) { click_button "I am now ready" }

      it "updates readiness status" do
        submit_form
        expect(me.reload).to be_ready_to_apply
      end

      context "when I previously provided an unreadiness reason" do
        let(:reason) {"meow"}
        it "doesn't change the unreadiness reason" do
          submit_form
          me.reload
          expect(me.readiness_status.unreadiness_reason).to eq "meow"
        end
      end

      context "when I am the account owner" do
        let(:i_am_owner) { true }
        it "tracks an event on Intercom", :intercom do
          expect{submit_form}.to \
            track_intercom_event("obs_ready_own").for_email(account.email)
        end
      end

      context "when I am the companion" do
        let(:i_am_owner) { false }
        it "tracks an event on Intercom", :intercom do
          expect{submit_form}.to \
            track_intercom_event("obs_ready_com").for_email(account.email)
        end
      end
    end

    describe "unready person clicks ready button" do
      let(:i_have_said_im_not_ready)  { true }
      before { click_button "I am now ready" }
      it "redirects to dashboard with success flash alert" do
        expect(current_path).to eq root_path
        expect(page).to have_success_message "Thanks! You will shortly receive your first card recommendation."
      end
    end

    describe "unanswered unready person" do
      it "redirects to person readiness new" do
        expect(current_path).to eq new_person_readiness_status_path(me)
      end
    end

    describe "ready person" do
      let(:i_am_already_ready)  { true }
      it "is redirected to dashboard" do
        expect(current_path).to eq root_path
      end
    end

    context "when I'm not eligible to apply for cards" do
      let(:i_am_eligible) { false }
      it "redirects to the dashboard" do
        expect(current_path).to eq root_path
      end

    end

  end
end
