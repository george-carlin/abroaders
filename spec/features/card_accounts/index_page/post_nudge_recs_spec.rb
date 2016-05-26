
require "rails_helper"

describe "user cards page - reconsidered cards", :js do

  include_context "logged in"

  let(:me) { account.main_passenger }

  let(:recommended_at) { 6.days.ago.to_date  }
  let(:applied_at)     { 5.days.ago.to_date }
  let(:nudged_at)      { 4.days.ago.to_date }

  before do
    @rec = create(
      :card_recommendation,
      recommended_at: recommended_at,
      applied_at: applied_at,
      nudged_at:  nudged_at,
      person: me
    )
    visit card_accounts_path
  end
  let(:rec) { @rec }
  let(:rec_on_page) { PostNudgeCardAccountOnPage.new(rec, self) }

  subject { rec_on_page }

  it "says when I applied", :frontend do
    is_expected.to have_content "Applied: #{applied_at.strftime("%D")}"
  end

  it "doesn't have apply/decline or 'I applied'/'I called' buttons", :frontend do
    is_expected.to have_no_apply_btn
    is_expected.to have_no_decline_btn
    is_expected.to have_no_i_applied_btn
    is_expected.to have_no_i_called_btn
  end

  it "has a button to say I heard back", :frontend do
    is_expected.to have_i_heard_back_btn
  end

  describe "clicking 'I heard back'" do
    before { rec_on_page.click_i_heard_back_btn }

    shared_examples "asks to confirm" do
      it "asks to confirm", :frontend do
        is_expected.to have_no_approved_btn
        is_expected.to have_no_denied_btn
        is_expected.to have_cancel_btn
        is_expected.to have_confirm_btn
      end

      describe "and clicking 'cancel'" do
        before { rec_on_page.click_cancel_btn }
        it "goes back a step", :frontend do
          is_expected.to have_approved_btn
          is_expected.to have_denied_btn
          is_expected.to have_no_confirm_btn
        end
      end
    end

    it "asks me the result", :frontend do
      is_expected.to have_no_i_called_btn
      is_expected.to have_approved_btn
      is_expected.to have_denied_btn
    end

    describe "clicking 'I was approved'" do
      before { rec_on_page.click_approved_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          rec.reload
        end

        it "marks the rec as 'open'", :backend do
          expect(rec.status).to eq "open"
        end

        it "sets 'opened_at' to the current date", :backend do
          expect(rec.opened_at).to eq Date.today
        end

        it "doesn't change any other timestamp", :backend do
          expect(rec.applied_at).to eq applied_at
          expect(rec.nudged_at).to eq nudged_at
          expect(rec.called_at).to be_nil
          expect(rec.redenied_at).to be_nil
          expect(rec.denied_at).to be_nil
        end
      end
    end

    describe "clicking 'I was denied'" do
      before { rec_on_page.click_denied_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          rec.reload
        end

        it "marks the rec as 'denied'", :backend do
          expect(rec.status).to eq "denied"
        end

        it "sets 'denied_at' to the current time", :backend do
          expect(rec.denied_at).to eq Date.today
        end

        it "doesn't change any other timestamp", :backend do
          expect(rec.applied_at).to eq applied_at
          expect(rec.nudged_at).to eq nudged_at
          expect(rec.called_at).to be_nil
          expect(rec.redenied_at).to be_nil
        end
      end
    end
  end
end
