require 'rails_helper'

describe "notifications", :focus do
  include_context "logged in"
  let(:me) { account }

  subject { page }

  before do
    extra_setup
    visit root_path
  end

  def within_navbar
    within("#main_navbar") { yield }
  end

  def click_notifications_in_navbar
    find("li.dropdown").click
  end

  def notification_selector(notification)
    "##{dom_id(notification)}"
  end

  let(:notifications_icon) { "#notifications_navbar" }

  context "when I have unread notifications" do
    let(:extra_setup) do
      @notifications = 2.times.map { create(:unseen_notification, account: me) }
      # My seen notification:
      create(:seen_notification, account: me)
      other_account = create(:account)
      # Someone else's unseen notification:
      create(:unseen_notification, account: other_account)
      account.reload
    end
    let(:notifications) { @notifications }

    it "says so in the navbar" do
      raise unless account.unseen_notifications_count == 2 # sanity check
      within_navbar do
        is_expected.to have_content "Notifications (2)"
      end
    end

    it "lists my notifications in the dropdown menu", :js do
      click_notifications_in_navbar
      is_expected.to have_selector ".notification", count: 3
    end

    describe "clicking on a notification", :js do
      before do
        skip # urgh, not worth writing tests for these now, we're only going to change it when the new theme is in place
      end
      let(:notification) { @notifications[1] }
      before { click_notifications_in_navbar }

      let(:click) { find(notification_selector(notification)).click }

      it "marks the notification as seen" do
        click
        expect(notification.reload).to be_seen
      end

      it "takes me to the relevant path" do
        click
        expect(current_path).to eq card_accounts_path
      end

      it "decrements unseen_notifications_count" do
        expect{click}.to change{account.reload.unseen_notifications_count}.by(-1)
      end
    end
  end

  context "when I have no unread notifications" do
    let(:extra_setup) do
      2.times { create(:seen_notification, account: me) }
    end

    it "says so in the header" do
      within_navbar do
        is_expected.to have_selector something, text: /\ANotifications\z/
      end
    end
  end

end
