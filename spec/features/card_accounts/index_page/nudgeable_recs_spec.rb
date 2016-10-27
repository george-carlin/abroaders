require "rails_helper"

describe "user cards page - nudgeable cards", :js do
  include_context "logged in"

  let(:person) { account.owner }

  let(:recommended_at) { 7.days.ago.to_date }
  let(:applied_at) { 7.days.ago.to_date }
  let(:bp) { :personal }

  before do
    person.update!(eligible: true)
    @bank = create(:bank, name: "Chase")
    @card = create(:card, bank: @bank, bp: bp)
    @offer = create(:offer, card: @card)
    @rec = create(
      :card_recommendation,
      recommended_at: recommended_at,
      applied_at: applied_at,
      person: person,
      offer: @offer,
    )
    visit card_accounts_path
  end

  let(:rec)  { @rec }
  let(:bank) { @bank }
  let(:personal_no) { @bank.personal_phone }
  let(:business_no) { @bank.business_phone }

  let(:rec_on_page) { NudgeableCardAccountOnPage.new(rec, self) }

  shared_examples "clicking 'cancel'" do
    describe "and clicking 'cancel'" do
      before { rec_on_page.click_cancel_btn }

      it "goes back to the 'I called'/'I heard back' buttons", :frontend do
        expect(rec_on_page).to have_i_called_btn
        expect(rec_on_page).to have_i_heard_back_btn
        expect(rec_on_page).to have_no_approved_btn
        expect(rec_on_page).to have_no_denied_btn
        expect(rec_on_page).to have_no_pending_btn
      end
    end
  end

  example "nudgeable rec on page", :frontend do
    # has buttons:
    expect(rec_on_page).to have_i_called_btn
    expect(rec_on_page).to have_i_heard_back_btn
    expect(rec_on_page).to have_no_apply_btn
    expect(rec_on_page).to have_no_decline_btn
    expect(rec_on_page).to have_no_i_applied_btn
    # it encourages the user to call the bank:
    expect(rec_on_page).to have_content "We strongly recommend that you call #{bank.name}"
    expect(rec_on_page).to have_content(
      "You’re more than twice as likely to get approved if you call #{bank.name} "\
      "than if you wait for them to send your decision in the mail",
    )
  end

  context "for a personal card" do
    let(:bp) { :personal }
    it "gives me the bank's personal number" do
      expect(rec_on_page).to have_content "call #{bank.name} at #{personal_no}"
      expect(rec_on_page).to have_no_content business_no
    end
  end

  context "for a business card" do
    let(:bp) { :business }
    it "gives me the bank's business number" do
      expect(rec_on_page).to have_content "call #{bank.name} at #{business_no}"
      expect(rec_on_page).to have_no_content personal_no
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
          expect(rec_on_page).to have_no_confirm_btn
        end
      end
    end

    include_examples "clicking 'cancel'"

    it "asks for the result", :frontend do
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

        it "updates the rec's attributes", :backend do
          expect(rec.status).to eq "open"
          expect(rec.opened_at).to eq Date.today
          expect(rec.nudged_at).to eq Date.today
          expect(rec.applied_at).to eq applied_at # unchanged
        end
      end
    end

    describe "clicking 'I was denied'" do
      before { rec_on_page.click_denied_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the rec's attributes", :backend do
          expect(rec.status).to eq "denied"
          expect(rec.applied_at).to eq applied_at # unchanged
          expect(rec.denied_at).to eq Date.today
          expect(rec.nudged_at).to eq Date.today
        end
      end
    end

    describe "clicking 'I'm still waiting'" do
      before { rec_on_page.click_pending_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the rec's attributes", :backend do
          expect(rec.status).to eq "applied"
          expect(rec.applied_at).to eq applied_at # unchanged
          expect(rec.nudged_at).to eq Date.today
        end
      end
    end
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

    shared_examples "doesn't change applied or nudged" do
      it "doesn't change applied or set nudged", :backend do
        expect(rec.nudged_at).to be_nil
        expect(rec.applied_at).to eq applied_at
      end
    end

    it "asks for the result", :frontend do
      expect(rec_on_page).to have_no_i_called_btn
      expect(rec_on_page).to have_no_i_heard_back_btn
      expect(rec_on_page).to have_approved_btn
      expect(rec_on_page).to have_denied_btn
    end

    include_examples "clicking 'cancel'"

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

        it "updates the rec's attributes", :backend do
          expect(rec.status).to eq "open"
          expect(rec.opened_at).to eq Date.today
        end

        include_examples "doesn't change applied or nudged"
      end
    end

    describe "clicking 'I was denied'" do
      before { rec_on_page.click_denied_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          rec_on_page.click_confirm_btn
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the rec's attributes", :backend do
          expect(rec.status).to eq "denied"
          expect(rec.denied_at).to eq Date.today
        end

        include_examples "doesn't change applied or nudged"
      end
    end
  end
end
