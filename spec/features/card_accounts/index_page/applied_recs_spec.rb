require "rails_helper"

describe "user cards page - applied cards", :js do

  include_context "logged in"

  let(:me) { account.main_passenger }

  let(:recommended_at) { 7.days.ago.to_date  }
  let(:applied_at) { 7.days.ago.to_date }
  let(:bp) { :personal }

  before do
    @bank = Bank.find(1)
    @card = create(:card, bank_id: @bank.id, bp: bp)
    @offer = create(:offer, card: @card)
    @rec = create(
      :card_recommendation,
      recommended_at: recommended_at,
      applied_at: applied_at,
      person: me,
      offer: @offer,
    )
    visit card_accounts_path
  end
  let(:rec)  { @rec }
  let(:bank) { @bank }
  subject(:rec_on_page) { AppliedCardAccountOnPage.new(rec, self) }

  shared_examples "clicking 'cancel'" do
    describe "and clicking 'cancel'" do
      before { rec_on_page.click_cancel_btn }

      it "goes back to the 'I called'/'I heard back' buttons", :frontend do
        expect(rec_on_page).to have_i_called_btn
        expect(rec_on_page).to have_i_heard_back_btn
        expect(rec_on_page).to have_no_nudged_and_approved_btn
        expect(rec_on_page).to have_no_nudged_and_denied_btn
        expect(rec_on_page).to have_no_nudged_and_pending_btn
        expect(rec_on_page).to have_no_heard_back_and_approved_btn
        expect(rec_on_page).to have_no_heard_back_and_denied_btn
      end
    end
  end

  it "says when I applied", :frontend do
    expect(rec_on_page).to have_content "Applied: #{applied_at.strftime("%D")}"
  end

  it "doesn't have apply/decline or 'I applied' buttons", :frontend do
    expect(rec_on_page).to have_no_apply_btn
    expect(rec_on_page).to have_no_decline_btn
    expect(rec_on_page).to have_no_i_applied_btn
  end

  it "encourages me to call the bank", :frontend do
    is_expected.to have_content "We strongly recommend that you call #{bank.name}"
    is_expected.to have_content(
      "You’re more than twice as likely to get approved if you call #{bank.name} "\
      "than if you wait for them to send your decision in the mail"
    )
  end

  context "for a personal card" do
    let(:bp) { :personal }
    it "gives me the bank's personal number" do
      is_expected.to have_content "call #{bank.name} at 888-245-0625"
      is_expected.to have_no_content "800 453-9719"
    end
  end

  context "for a business card" do
    let(:bp) { :business }
    it "gives me the bank's business number" do
      is_expected.to have_content "call #{bank.name} at 800 453-9719"
      is_expected.to have_no_content "888-245-0625"
    end
  end


  it "has buttons to say I called or I heard back", :frontend do
    expect(rec_on_page).to have_i_called_btn
    expect(rec_on_page).to have_i_heard_back_btn
  end

  describe "clicking 'I called'" do
    before { rec_on_page.click_i_called_btn }

    shared_examples "asks to confirm" do
      it "asks to confirm", :frontend do
        expect(rec_on_page).to have_no_nudged_and_approved_btn
        expect(rec_on_page).to have_no_nudged_and_denied_btn
        expect(rec_on_page).to have_no_nudged_and_pending_btn
        expect(rec_on_page).to have_cancel_btn
        expect(rec_on_page).to have_confirm_btn
      end

      describe "and clicking 'cancel'" do
        before { rec_on_page.click_cancel_btn }
        it "goes back a step", :frontend do
          expect(rec_on_page).to have_nudged_and_approved_btn
          expect(rec_on_page).to have_nudged_and_denied_btn
          expect(rec_on_page).to have_nudged_and_pending_btn
          expect(rec_on_page).to have_no_confirm_btn
        end
      end
    end

    include_examples "clicking 'cancel'"

    it "asks me the result", :frontend do
      expect(rec_on_page).to have_no_i_called_btn
      expect(rec_on_page).to have_nudged_and_approved_btn
      expect(rec_on_page).to have_nudged_and_denied_btn
      expect(rec_on_page).to have_nudged_and_pending_btn
    end

    describe "clicking 'I was approved'" do
      before { rec_on_page.click_nudged_and_approved_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          rec.reload
        end

        it "marks the rec as 'open'", :backend do
          expect(rec.status).to eq "open"
        end

        it "sets 'opened_at' and 'nudged_at' to the current date", :backend do
          expect(rec.opened_at).to eq Date.today
          expect(rec.nudged_at).to eq Date.today
        end

        it "doesn't change applied_at", :backend do
          expect(rec.applied_at).to eq applied_at
        end
      end
    end

    describe "clicking 'I was denied'" do
      before { rec_on_page.click_nudged_and_denied_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          rec.reload
        end

        it "marks the rec as 'denied'", :backend do
          expect(rec.status).to eq "denied"
        end

        it "doesn't change 'applied_at'", :backend do
          expect(rec.applied_at).to eq applied_at
        end

        it "sets 'denied_at' and 'nudged_at' to the current time", :backend do
          expect(rec.denied_at).to eq Date.today
          expect(rec.nudged_at).to eq Date.today
        end
      end
    end

    describe "clicking 'I'm still waiting'" do
      before { rec_on_page.click_nudged_and_pending_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          rec.reload
        end

        it "doesn't change the rec's status or 'applied_at' timestamp", :backend do
          expect(rec.status).to eq "applied"
          expect(rec.applied_at).to eq applied_at
        end

        it "sets 'nudged_at' to the current time", :backend do
          expect(rec.nudged_at).to eq Date.today
        end
      end
    end
  end

  describe "clicking 'I heard back'" do
    before { rec_on_page.click_i_heard_back_btn }

    shared_examples "asks to confirm" do
      it "asks to confirm", :frontend do
        expect(rec_on_page).to have_no_heard_back_and_approved_btn
        expect(rec_on_page).to have_no_heard_back_and_denied_btn
        expect(rec_on_page).to have_cancel_btn
        expect(rec_on_page).to have_confirm_btn
      end

      describe "and clicking 'cancel'" do
        before { rec_on_page.click_cancel_btn }
        it "goes back a step", :frontend do
          expect(rec_on_page).to have_heard_back_and_approved_btn
          expect(rec_on_page).to have_heard_back_and_denied_btn
          expect(rec_on_page).to have_no_confirm_btn
        end
      end
    end

    shared_examples "doesn't change applied or nudged" do
      it "doesn't set 'nudged_at'", :backend do
        expect(rec.nudged_at).to be_nil
      end

      it "doesn't change applied_at", :backend do
        expect(rec.applied_at).to eq applied_at
      end
    end

    it "asks me the result", :frontend do
      expect(rec_on_page).to have_no_i_called_btn
      expect(rec_on_page).to have_no_i_heard_back_btn
      expect(rec_on_page).to have_heard_back_and_approved_btn
      expect(rec_on_page).to have_heard_back_and_denied_btn
    end

    include_examples "clicking 'cancel'"

    describe "clicking 'I was approved'" do
      before { rec_on_page.click_heard_back_and_approved_btn }

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

        include_examples "doesn't change applied or nudged"
      end
    end

    describe "clicking 'I was denied'" do
      before { rec_on_page.click_heard_back_and_denied_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          rec.reload
        end

        it "marks the rec as 'denied'", :backend do
          expect(rec.status).to eq "denied"
        end

        it "sets 'denied_at' to the current date", :backend do
          expect(rec.denied_at).to eq Date.today
        end

        include_examples "doesn't change applied or nudged"
      end
    end
  end
end
