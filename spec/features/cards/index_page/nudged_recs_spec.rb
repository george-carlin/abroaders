require "rails_helper"

describe "user cards page - nudged cards", :js do
  include ApplicationSurveyMacros
  include_context "logged in"

  let(:person) { account.owner }

  let(:recommended_at) { 6.days.ago.to_date }
  let(:applied_at)     { 5.days.ago.to_date }
  let(:nudged_at)      { 4.days.ago.to_date }

  let(:approved_btn) { 'My application was approved' }
  let(:denied_btn)   { 'My application was declined' }

  before do
    person.update!(eligible: true)
    @rec = create(
      :card_recommendation,
      recommended_at: recommended_at,
      applied_at: applied_at,
      nudged_at:  nudged_at,
      person: person,
    )
    visit cards_path
  end
  let(:rec) { @rec }
  let(:rec_on_page) { NudgedCardOnPage.new(rec, self) }

  example "rec on page", :frontend do
    expect(page).to have_no_apply_btn(rec)
    expect(page).to have_no_button decline_btn
    expect(page).to have_no_button i_applied_btn
    expect(page).to have_no_button i_called_btn(rec)
    expect(page).to have_button i_heard_back_btn
  end

  describe "clicking 'I heard back'" do
    before { rec_on_page.click_i_heard_back_btn }

    shared_examples "asks to confirm" do
      it "asks to confirm", :frontend do
        expect(page).to have_no_button approved_btn
        expect(page).to have_no_button denied_btn
        expect(page).to have_button 'Cancel'
        expect(page).to have_button 'Confirm'
      end

      describe "and clicking 'cancel'" do
        before { click_button 'Cancel' }
        it "goes back a step", :frontend do
          expect(page).to have_button approved_btn
          expect(page).to have_button denied_btn
          expect(page).to have_no_button 'Confirm'
        end
      end
    end

    it "asks for the result", :frontend do
      expect(page).to have_no_button i_called_btn(rec)
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
    end

    describe "clicking 'I was approved'" do
      before { rec_on_page.click_approved_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          click_button 'Confirm'
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          expect(rec.status).to eq "open"
          expect(rec.opened_at).to eq Time.zone.today
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
          click_button 'Confirm'
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          expect(rec.status).to eq "denied"
          expect(rec.denied_at).to eq Time.zone.today
          expect(rec.applied_at).to eq applied_at # unchanged
          expect(rec.nudged_at).to eq nudged_at # unchanged
          expect(rec.called_at).to be_nil # unchanged
          expect(rec.redenied_at).to be_nil # unchanged
        end
      end
    end
  end
end
