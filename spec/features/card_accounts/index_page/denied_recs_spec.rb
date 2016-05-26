require "rails_helper"

describe "user cards page - denied cards", :js do

  subject { page }

  include_context "logged in"

  let(:me) { account.main_passenger }

  let(:recommended_at) { 7.days.ago.to_date  }
  let(:applied_at) { 7.days.ago.to_date }
  let(:denied_at)  { 5.days.ago.to_date }

  before do
    @rec = create(
      :denied_card_recommendation,
      recommended_at: recommended_at,
      applied_at: applied_at,
      denied_at: denied_at,
      person: me
    )
    visit card_accounts_path
  end
  let(:rec) { @rec }
  let(:rec_on_page) { DeniedCardAccountOnPage.new(rec, self) }

  it "says when I applied and got denied", :frontend do
    expect(rec_on_page).to have_content "Applied: #{applied_at.strftime("%D")}"
    expect(rec_on_page).to have_content "Denied: #{denied_at.strftime("%D")}"
  end

  it "doesn't have apply/decline or 'I applied' buttons", :frontend do
    expect(rec_on_page).to have_no_apply_btn
    expect(rec_on_page).to have_no_decline_btn
    expect(rec_on_page).to have_no_i_applied_btn
  end

  it "encourages me to call the bank", :frontend do
    expect(rec_on_page).to have_content(
      "We strongly recommend that you call BANK at BANK PERSONAL/BIZ PHONE "\
      "as soon as possible to ask for a real person to review your "\
      "application by phone."
    )
    expect(rec_on_page).to have_content(
      "More than 30% of applications that are initially denied are "\
      "overturned with a 5-10 minute phone call."
    )
  end

  it "has a button to say I called", :frontend do
    expect(rec_on_page).to have_i_called_btn
  end

  context "when bank is Barclays", :frontend do
    it "doesn't encourage me to call"
    # Barclays is the one bank which won't reconsider denied applications
  end

  describe "clicking 'I called'" do
    before { rec_on_page.click_i_called_btn }

    shared_examples "asks to confirm" do
      it "asks to confirm", :frontend do
        expect(rec_on_page).to have_no_approved_btn
        expect(rec_on_page).to have_no_denied_btn
        expect(rec_on_page).to have_no_pending_btn
        expect(rec_on_page).to have_cancel_btn
        expect(rec_on_page).to have_confirm_btn
      end

      describe "and clicking 'cancel'" do
        before { rec_on_page.click_cancel_btn }
        it "goes back a step", :frontend do
          expect(rec_on_page).to have_approved_btn
          expect(rec_on_page).to have_denied_btn
          expect(rec_on_page).to have_pending_btn
          expect(rec_on_page).to have_no_cancel_btn
          expect(rec_on_page).to have_no_confirm_btn
        end
      end
    end

    it "asks me the result", :frontend do
      expect(rec_on_page).to have_no_i_called_btn
      expect(rec_on_page).to have_approved_btn
      expect(rec_on_page).to have_denied_btn
      expect(rec_on_page).to have_pending_btn
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

        it "sets 'opened_at' and 'called_at' to the current date", :backend do
          expect(rec.opened_at).to eq Date.today
          expect(rec.called_at).to eq Date.today
        end

        it "doesn't change applied_at" do
          expect(rec.applied_at).to eq applied_at
        end
      end
    end

    describe "clicking 'I was denied again'" do
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

        it "doesn't change 'denied_at' or 'applied_at'", :backend do
          expect(rec.denied_at).to eq denied_at
          expect(rec.applied_at).to eq applied_at
        end

        it "sets 'redenied_at' and 'called_at' to the current time", :backend do
          expect(rec.redenied_at).to eq Date.today
          expect(rec.called_at).to eq Date.today
        end
      end
    end

    describe "clicking 'I'm now pending'" do
      before { rec_on_page.click_pending_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          rec.reload
        end

        it "marks the rec as 'pending reconsideration'", :backend do
          expect(rec.status).to eq "denied"
        end

        it "doesn't change 'denied_at' or 'applied_at'", :backend do
          expect(rec.denied_at).to eq denied_at
          expect(rec.applied_at).to eq applied_at
        end

        it "sets 'called_at' to the current time", :backend do
          expect(rec.called_at).to eq Date.today
        end

        it "doesn't set 'redenied_at' or 'opened_at'", :backend do
          expect(rec.opened_at).to be_nil
          expect(rec.redenied_at).to be_nil
        end
      end
    end
  end
end
