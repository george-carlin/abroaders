require "rails_helper"

describe "the 'are you ready to apply?' survey page", :js, :onboarding do
  subject { page }

  let!(:account) { create(:account) }
  let!(:me) { account.people.first }

  before do
    # if already_ready?
    #   create(:readiness_status, person: me, ready: true)
    #   me.reload
    # end
    # if has_companion?
    #   create(:person, account: account, main: false)
    # end
    login_as(account.reload)
  end

  context "when I'm not eligible to apply for cards" do
    let(:already_ready?) { true }
    it "redirects to the dashboard" do
      expect(current_path).to eq root_path
    end
  end

    visit new_person_readiness_status_path(me)

  let(:i_have_already_answered_this_survey?) { false }
  let(:i_am_eligible_to_apply?)              { true }
  let(:i_am_companion?)                      { false }
  let(:i_have_companion?)                    { false }
  let(:companion_is_eligible_to_apply?)      { false }

  shared_examples "survey complete" do
    context "when I've already added a companion" do
      let(:has_companion?) { true }
      it "takes me to my dashboard" do
        expect(current_path).to eq root_path
      end
    end

    context "when I haven't added a companion" do
      it "takes me to the new companion page" do
        expect(current_path).to eq new_companion_path
      end
    end
  end

  it "has radio buttons to say I'm ready or not ready" do
    is_expected.to have_field :readiness_status_ready_true
    is_expected.to have_field :readiness_status_ready_false
  end

  specify "'I'm ready' is selected by default" do
    expect(find("#readiness_status_ready_true")).to be_checked
  end

  describe "submitting the form" do
    before { click_button "Confirm" }

    it "marks me as ready to apply" do
      me.reload
      expect(me.readiness_status_given?).to be_truthy
      expect(me).to be_ready_to_apply
    end

    include_examples "survey complete"
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
        before { click_button "Confirm" }

        include_examples "survey complete"

        it "saves my status as 'not ready to reply'" do
          me.reload
          expect(me.readiness_status_given?).to be_truthy
          expect(me).to be_unready_to_apply
        end
      end
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
      before { click_button "Confirm" }

      it "saves my status as 'not ready to reply'" do
        me.reload
        expect(me.readiness_status_given?).to be_truthy
        expect(me).to be_unready_to_apply
        expect(me.unreadiness_reason).to be_blank
      end

      include_examples "survey complete"

      it "queues a reminder email"
    end
  end
end

