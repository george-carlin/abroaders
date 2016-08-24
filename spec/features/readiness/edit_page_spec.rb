require "rails_helper"

describe "edit readiness page", :js do
  let(:account) { create(:account, :onboarded_cards, :onboarded_balances) }
  let(:me)      { account.owner }

  before do
    if i_have_said_im_not_ready
      me.unready!(reason: reason)
    end

    login_as(account)
    visit person_readiness_path(me)
  end

  let(:i_have_said_im_not_ready) { false }
  let(:reason) { nil }

  describe "explicitly unready person" do
    let(:i_have_said_im_not_ready)  { true }
    let(:reason) { "meow" }
    it "shows and readiness" do
      expect(page).to have_content me.readiness.unreadiness_reason
    end
  end

  describe "unready person clicks ready button" do
    let(:i_have_said_im_not_ready)  { true }
    let(:submit_form) { click_button "I am now ready" }

    it "updates readiness status", :js do
      submit_form
      expect(me.reload).to be_ready
    end

    context "when I previously provided an unreadiness reason" do
      let(:reason) {"meow"}
      it "doesn't change the unreadiness reason" do
        submit_form
        me.reload
        expect(me.unreadiness_reason).to eq "meow"
      end
    end

    it "tracks an event on Intercom", :intercom do
      expect{submit_form}.to \
        track_intercom_event("obs_ready_own").for_email(account.email)
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
end
