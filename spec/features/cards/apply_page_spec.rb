require "rails_helper"

RSpec.describe "card recommendation apply page" do
  subject { page }

  include_context "logged in"

  let(:me) { account.owner }

  let(:rec) { create_card_recommendation(person_id: me.id) }

  let(:visit_path) { visit apply_card_recommendation_path(rec) }

  # TODO How can we test this?
  it "redirects to the bank's page after a delay"

  context "when the recommendation has not been clicked before" do
    before { raise unless rec.status == "recommended" && rec.clicked_at.nil? } # sanity checks

    it "saves the 'clicked at' timestamp" do
      visit_path
      expect(rec.reload.clicked_at).to be_within(5.seconds).of(Time.zone.now)
    end
  end

  context "when the account has been clicked before" do
    before { rec.update_attributes!(clicked_at: 10.days.ago) }

    it "updates the 'clicked at' timestamp" do
      visit_path
      expect(rec.reload.clicked_at).to be_within(5.seconds).of(Time.zone.now)
    end
  end

  context "when the card account was added in onboarding" do
    let(:rec) { create_card_account(person: me) }

    skip "doesn't set 'clicked at'" do # move to controller test
      expect { visit_path }.to change { rec.reload.clicked_at }
    end
  end

  pending "test other statuses and decide how to handle them"
end
