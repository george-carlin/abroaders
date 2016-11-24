require 'rails_helper'

describe "notifications" do
  include_context "logged in"
  let(:me) { account }

  before do
    extra_setup
    visit root_path
  end

  def within_navbar
    within("#header") { yield }
  end

  def click_notifications_in_navbar
    find("li.dropdown.unseen_notifications").click
  end

  def notification_selector(notification)
    "##{dom_id(notification)}"
  end

  let(:notifications_icon) { "#notifications_navbar" }

  context "when I have unread notifications" do
    let(:extra_setup) do
      @notifications = Array.new(2) { create(:unseen_notification, account: me) }
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
        expect(page).to have_selector ".unseen_notifications .label", text: 2
      end
    end

    it "lists my notifications in the dropdown menu", :js do
      click_notifications_in_navbar
      expect(page).to have_selector ".notification", count: 2
    end

    describe "clicking on a notification", :js do
      let(:notification) { @notifications[1] }
      before { click_notifications_in_navbar }

      let(:click) { find(notification_selector(notification)).click }

      it "marks the notification as seen" do
        click
        expect(notification.reload).to be_seen
      end

      it "takes me to the relevant path" do
        click
        expect(current_path).to eq cards_path
      end

      it "decrements unseen_notifications_count" do
        expect { click }.to change { account.reload.unseen_notifications_count }.by(-1)
      end
    end
  end

  context "when I have no unread notifications" do
    let(:extra_setup) do
      2.times { create(:seen_notification, account: me) }
    end

    it "doesn't mention them in the header" do
      within_navbar do
        expect(page).to have_no_selector ".unseen_notifications .label"
      end
    end
  end
end
