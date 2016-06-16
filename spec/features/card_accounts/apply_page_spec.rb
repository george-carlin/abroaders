require "rails_helper"

describe "card recommendation apply page" do
  subject { page }

  include_context "logged in"

  let(:me) { account.main_passenger }

  let(:rec) { create(:card_recommendation, person: me) }

  let(:visit_path) { visit apply_card_recommendation_path(rec) }

  # TODO How can we test this?
  it "redirects to the bank's page after a delay"

  context "when the recommendation has not been clicked before" do
    before { raise unless rec.status == "recommended" && rec.clicked_at.nil?  } # sanity checks

    it "saves the 'clicked at' timestamp" do
      visit_path
      expect(rec.reload.clicked_at).to eq Date.today
    end
  end

  context "when the account has been clicked before" do
    before { rec.update_attributes!(clicked_at: 10.days.ago) }

    it "updates the 'clicked at' timestamp" do
      visit_path
      expect(rec.reload.clicked_at).to eq Date.today
    end
  end

  context "when the card account was added in onboarding" do
    let(:rec) { create(:card_account, :survey, person: me) }

    it "redirects back to the card index page" do
      visit_path
      expect(current_path).to eq card_accounts_path
    end

    it "doesn't set 'clicked at'" do
      expect{visit_path}.not_to change{rec.reload.clicked_at}
    end
  end

  pending "test other statuses and decide how to handle them"
end
