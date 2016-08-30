require "rails_helper"

describe "user cards page - callable cards", :js do

  include_context "logged in"

  let(:me) { account.owner }

  let(:recommended_at) { 7.days.ago.to_date  }
  let(:applied_at) { 7.days.ago.to_date }
  let(:denied_at)  { 5.days.ago.to_date }
  let(:bp) { :personal }

  before do
    @bank = Bank.find(1)
    @card  = create(:card, bank_id: @bank.id, bp: bp)
    @offer = create(:offer, card: @card)
    @rec = create(
      :denied_card_recommendation,
      recommended_at: recommended_at,
      applied_at: applied_at,
      denied_at: denied_at,
      person: me,
      offer: @offer,
    )
    visit card_accounts_path
  end
  let(:rec) { @rec }
  let(:rec_on_page) { CallableCardAccountOnPage.new(rec, self) }

  example "rec on page", :frontend do
    expect(rec_on_page).to have_no_apply_btn
    expect(rec_on_page).to have_no_decline_btn
    expect(rec_on_page).to have_no_i_applied_btn
    expect(rec_on_page).to have_content "We strongly recommend that you call #{@bank.name}"
    expect(rec_on_page).to have_content(
      "More than 30% of applications that are initially denied are "\
      "overturned with a 5-10 minute phone call."
    )
    expect(rec_on_page).to have_i_called_btn
  end

  context "for a personal card" do
    let(:bp) { :personal }
    it "gives me the bank's personal number" do
      expect(rec_on_page).to have_content "call #{@bank.name} at 888-245-0625"
      expect(rec_on_page).to have_no_content "800 453-9719"
    end
  end

  context "for a business card" do
    let(:bp) { :business }
    it "gives me the bank's business number" do
      expect(rec_on_page).to have_content "call #{@bank.name} at 800 453-9719"
      expect(rec_on_page).to have_no_content "888-245-0625"
    end
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
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          expect(rec.status).to eq "open"
          expect(rec.opened_at).to eq Date.today
          expect(rec.called_at).to eq Date.today
          expect(rec.applied_at).to eq applied_at # unchanged
        end
      end
    end

    describe "clicking 'I was denied again'" do
      before { rec_on_page.click_denied_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          expect(rec.status).to eq "denied"
          expect(rec.denied_at).to eq denied_at
          expect(rec.applied_at).to eq applied_at # unchanged
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
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          expect(rec.status).to eq "denied"
          expect(rec.denied_at).to eq denied_at
          expect(rec.applied_at).to eq applied_at # unchanged
          expect(rec.called_at).to eq Date.today
          # doesn't set:
          expect(rec.opened_at).to be_nil
          expect(rec.redenied_at).to be_nil
        end
      end
    end
  end
end
