require "rails_helper"

describe "readiness survey", :js, :onboarding do
  include_context "set admin email ENV var"
  subject { page }

  let(:account) do
    create(:account, onboarded_travel_plans: true, onboarded_type: true)
  end

  before do
    account.owner.update_attributes!(
      eligible: true,
      onboarded_balances: true,
      onboarded_cards:    true,
    )
    create(:spending_info, person: account.owner)
    if i_am_owner
      @me = account.owner
    else
      account.owner.update_attributes(ready: true)
      @me = create(
        :person,
        :companion,
        :onboarded_spending,
        account: account,
        eligible:           true,
        onboarded_balances: true,
        onboarded_cards:    true,
        owner:              false,
      )
    end

    me.update_attributes!(ready: true) if i_am_already_ready

    login_as(account.reload)
    visit new_person_readiness_path(me)
  end

  let(:me) { @me }

  let(:i_am_owner)         { true }
  let(:i_am_already_ready) { false }


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

  it "has radio buttons to say I'm ready or not ready" do
    is_expected.to have_field :person_ready_true
    is_expected.to have_field :person_ready_false
  end

  it "doesn't show the sidebar" do
    expect(page).to have_no_selector "#menu"
  end

  pending "it shows the sidebar if I'm onboarded but previously said I wasn't ready"

  specify "'I'm ready' is selected by default" do
    expect(find("#person_ready_true")).to be_checked
  end

  describe "submitting the form" do
    it "marks me as ready to apply" do
      submit_form
      me.reload
      expect(me.onboarded_readiness?).to be_truthy
      expect(me).to be_ready
    end

    include_examples "track intercom event", true
  end

  describe "selecting 'I'm not ready'" do
    before { choose :person_ready_false }

    def unreadiness_reason_field
      :person_unreadiness_reason
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
          expect(me.onboarded_readiness?).to be_truthy
          expect(me).to be_unready
        end
      end

      include_examples "track intercom event", false
    end

    describe "and clicking 'cancel'" do
      before { choose :person_ready_true }

      describe "and clicking 'not ready' again" do
        before { choose :person_ready_false }

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
        expect(me.onboarded_readiness?).to be_truthy
        expect(me).to be_unready
        expect(me.unreadiness_reason).to be_blank
      end

      it "queues a reminder email"

      include_examples "track intercom event", false
    end
  end

  describe "after submit" do
    before do
      if i_have_a_partner
        @partner = account.create_companion!(
          eligible: partner_is_eligible,
          first_name: "Somebody",
        )
      end
    end

    let(:i_have_a_partner) { false }
    let(:partner) { @partner }

    context "when I am the main person on the account" do
      let(:i_am_owner) { true }

      context "and I have a partner on the account" do
        let(:i_have_a_partner) { true }

        context "who is eligible to apply for cards" do
          let(:partner_is_eligible) { true }
          it "takes me to the partner's spending survey" do
            submit_form
            expect(current_path).to eq new_person_spending_info_path(partner)
          end

          include_examples "don't send any emails"
        end

        context "who is ineligible to apply for cards" do
          let(:partner_is_eligible) { false }
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
