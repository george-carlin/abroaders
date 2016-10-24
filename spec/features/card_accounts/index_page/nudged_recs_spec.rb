
require "rails_helper"

describe "user cards page - nudged cards", :js do
  include_context "logged in"

  let(:me) { account.owner }

  let(:recommended_at) { 6.days.ago.to_date }
  let(:applied_at)     { 5.days.ago.to_date }
  let(:nudged_at)      { 4.days.ago.to_date }

  before do
    @rec = create(
      :card_recommendation,
      recommended_at: recommended_at,
      applied_at: applied_at,
      nudged_at:  nudged_at,
      person: me,
    )
    visit card_accounts_path
  end
  let(:rec) { @rec }
  let(:rec_on_page) { NudgedCardAccountOnPage.new(rec, self) }

  example "rec on page", :frontend do
    expect(rec_on_page).to have_no_apply_btn
    expect(rec_on_page).to have_no_decline_btn
    expect(rec_on_page).to have_no_i_applied_btn
    expect(rec_on_page).to have_no_i_called_btn
    expect(rec_on_page).to have_i_heard_back_btn
  end

  describe "clicking 'I heard back'" do
    before { rec_on_page.click_i_heard_back_btn }

    shared_examples "asks to confirm" do
      it "asks to confirm", :frontend do
        expect(rec_on_page).to have_no_approved_btn
        expect(rec_on_page).to have_no_denied_btn
        expect(rec_on_page).to have_cancel_btn
        expect(rec_on_page).to have_confirm_btn
      end

      describe "and clicking 'cancel'" do
        before { rec_on_page.click_cancel_btn }
        it "goes back a step", :frontend do
          expect(rec_on_page).to have_approved_btn
          expect(rec_on_page).to have_denied_btn
          expect(rec_on_page).to have_no_confirm_btn
        end
      end
    end

    it "asks me the result", :frontend do
      expect(rec_on_page).to have_no_i_called_btn
      expect(rec_on_page).to have_approved_btn
      expect(rec_on_page).to have_denied_btn
    end

    describe "clicking 'I was approved'" do
      before { rec_on_page.click_approved_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          expect(rec.status).to eq "open"
          expect(rec.opened_at).to eq Date.today
          expect(rec.applied_at).to eq applied_at # unchanged
          expect(rec.nudged_at).to eq nudged_at # unchanged
          expect(rec.called_at).to be_nil # unchanged
          expect(rec.redenied_at).to be_nil # unchanged
          expect(rec.denied_at).to be_nil # unchanged
        end
      end
    end

    describe "clicking 'I was denied'" do
      before { rec_on_page.click_denied_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          expect(rec.status).to eq "denied"
          expect(rec.denied_at).to eq Date.today
          expect(rec.applied_at).to eq applied_at # unchanged
          expect(rec.nudged_at).to eq nudged_at # unchanged
          expect(rec.called_at).to be_nil # unchanged
          expect(rec.redenied_at).to be_nil # unchanged
        end
      end
    end
  end
end
