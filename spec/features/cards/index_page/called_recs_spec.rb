require "rails_helper"

RSpec.describe "user cards page - called cards", :js do
  include ApplicationSurveyMacros
  subject { page }

  include_context "logged in"

  let(:person) { account.owner }

  let(:recommended_at) { 6.days.ago.to_date }
  let(:applied_at)     { 5.days.ago.to_date }
  let(:denied_at)      { 4.days.ago.to_date }
  let(:called_at)      { 3.days.ago.to_date }

  # override variables set by ApplicationSurveyMacros:
  let(:approved_btn) { 'My application was approved after reconsideration' }
  let(:denied_btn)   { 'My application is still denied' }

  before do
    person.update!(eligible: true)
    @rec = create(
      :card_recommendation,
      recommended_at: recommended_at,
      applied_at: applied_at,
      denied_at:  denied_at,
      called_at:  called_at,
      person:     person,
    )
    visit cards_path
  end
  let(:rec) { @rec }

  example "rec on page", :frontend do
    expect(page).to have_no_apply_btn(rec)
    expect(page).to have_no_button decline_btn
    expect(page).to have_no_button i_applied_btn
    expect(page).to have_no_button i_called_btn(rec)
    expect(page).to have_button i_heard_back_btn
  end

  describe "clicking 'I heard back'" do
    before { click_button i_heard_back_btn }

    shared_examples "asks to confirm" do
      it "asks to confirm", :frontend do
        expect(page).to have_no_button approved_btn
        expect(page).to have_no_button denied_btn
        expect(page).to have_button 'Cancel'
        expect(page).to have_button 'Confirm'
        # going back
        click_button 'Cancel'
        expect(page).to have_button approved_btn
        expect(page).to have_button denied_btn
        expect(page).to have_no_button 'Confirm'
      end
    end

    it "asks person the result", :frontend do
      expect(page).to have_no_button i_called_btn(rec)
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
    end

    describe "clicking 'I was approved'" do
      before { click_button approved_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          click_button 'Confirm'
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          # this spec fails when run late in the day when your machine's time
          # is earlier than UTC # TZFIXME
          expect(rec.status).to eq "open"
          expect(rec.opened_at).to eq Time.zone.today
          expect(rec.applied_at).to eq applied_at # unchanged
          expect(rec.denied_at).to eq denied_at # unchanged
          expect(rec.called_at).to eq called_at # unchanged
          expect(rec.redenied_at).to be_nil # not set
        end
      end
    end

    describe "clicking 'I was denied'" do
      before { click_button denied_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          click_button 'Confirm'
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          # this spec fails when run late in the day when your machine's time
          # is earlier than UTC # TZFIXME
          expect(rec.status).to eq "denied"
          expect(rec.redenied_at).to eq Time.zone.today
          expect(rec.applied_at).to eq applied_at # unchanged
          expect(rec.denied_at).to eq denied_at # unchanged
          expect(rec.called_at).to eq called_at # unchanged
        end
      end
    end
  end
end
