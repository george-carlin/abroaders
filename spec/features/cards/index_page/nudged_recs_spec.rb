require "rails_helper"

RSpec.describe "user cards page - nudged cards", :js do
  include ApplicationSurveyMacros
  include ZapierWebhooksMacros

  include_context "logged in"

  let(:person) { account.owner }

  let(:recommended_at) { 6.days.ago.to_date }
  let(:applied_on)     { 5.days.ago.to_date }
  let(:nudged_at)      { 4.days.ago.to_date }

  let(:approved_btn) { 'My application was approved' }
  let(:denied_btn)   { 'My application was declined' }

  before do
    person.update!(eligible: true)
    @rec = create_card_recommendation(person_id: person.id)
    @rec.update!(recommended_at: recommended_at, applied_on: applied_on, nudged_at: nudged_at)
    visit cards_path
  end
  let(:rec) { @rec }

  example "rec on page", :frontend do
    expect(page).to have_no_find_card_btn(rec)
    expect(page).to have_no_button decline_btn
    expect(page).to have_no_button i_applied_btn
    expect(page).to have_no_button i_called_btn(rec)
    expect(page).to have_button i_heard_back_btn
  end

  describe "clicking 'I heard back'" do
    before { click_button i_heard_back_btn }

    it "asks for the result", :frontend do
      expect(page).to have_no_button i_called_btn(rec)
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
    end

    describe "clicking 'I was approved'" do
      before { click_button approved_btn }

      it_asks_to_confirm(has_pending_btn: false)

      example 'and clicking "confirm"' do
        click_button 'Confirm'
        sleep 1.5
        rec.reload

        # this spec fails when run late in the day when your machine's time
        # is earlier than UTC # TZFIXME
        expect(rec).to be_opened
        expect(rec.opened_on).to eq Time.zone.today
        expect(rec.applied_on).to eq applied_on # unchanged
        expect(rec.nudged_at).to eq nudged_at # unchanged
        expect(rec.called_at).to be_nil # unchanged
        expect(rec.redenied_at).to be_nil # unchanged
        expect(rec.denied_at).to be_nil # unchanged
      end
    end

    describe "clicking 'I was denied'" do
      before { click_button denied_btn }

      it_asks_to_confirm(has_pending_btn: false)

      example 'and clicking "confirm"' do
        click_button 'Confirm'
        sleep 1.5
        rec.reload

        expect(CardRecommendation.new(rec).status).to eq "denied"
        expect(rec.denied_at).to be_within(5.seconds).of(Time.zone.now)
        expect(rec.applied_on).to eq applied_on # unchanged
        expect(rec.nudged_at).to eq nudged_at # unchanged
        expect(rec.called_at).to be_nil # unchanged
        expect(rec.redenied_at).to be_nil # unchanged
      end
    end
  end
end
