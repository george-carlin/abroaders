require "rails_helper"

RSpec.describe "user cards page - callable cards", :js do
  include ApplicationSurveyMacros
  include ZapierWebhooksMacros

  let(:account) { create_account(:onboarded) }
  let(:person)  { account.owner }

  let(:recommended_at) { 7.days.ago.to_date }
  let(:applied_on) { 7.days.ago.to_date }
  let(:denied_at)  { 5.days.ago.to_date }
  let(:business) { false }

  # override variables set by ApplicationSurveyMacros:
  let(:approved_btn) { 'I was approved after reconsideration' }
  let(:denied_btn) { 'My application is still denied' }
  let(:pending_btn) { "I'm being reconsidered, but waiting to hear back about whether it was successful" }

  before do
    person.update!(eligible: true)
    login_as_account(account)
    @bank    = Bank.all.first
    @product = create(:card_product, bank_id: @bank.id, business: business)
    @offer = create_offer(card_product: @product)
    @rec = create_card_recommendation(person_id: person.id, offer_id: @offer.id)
    @rec.update!(recommended_at: recommended_at, applied_on: applied_on, denied_at: denied_at)
    visit cards_path
  end
  let(:rec) { @rec }

  let(:personal_phone) { @bank.personal_phone }
  let(:business_phone) { @bank.business_phone }

  example "rec on page", :frontend do
    expect(page).to have_no_find_card_btn(rec)
    expect(page).to have_no_button decline_btn
    expect(page).to have_no_button i_applied_btn
    expect(page).to have_content "We strongly recommend that you call #{@bank.name}"
    expect(page).to have_content(
      "More than 30% of applications that are initially denied are "\
      "overturned with a 5-10 minute phone call.",
    )
    expect(page).to have_button i_called_btn(rec)
  end

  context "for a personal card product" do
    let(:business) { false }
    it "gives me the bank's personal number" do
      expect(page).to have_content "call #{@bank.name} at #{personal_phone}"
      expect(page).to have_no_content business_phone
    end
  end

  context "for a business card product" do
    let(:business) { true }
    it "gives me the bank's business number" do
      expect(page).to have_content "call #{@bank.name} at #{business_phone}"
      expect(page).to have_no_content personal_phone
    end
  end

  describe "clicking 'I called'" do
    before { click_button i_called_btn(rec) }

    it "asks for the result", :frontend do
      expect(page).to have_no_button i_called_btn(rec)
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
      expect(page).to have_button pending_btn
    end

    describe "clicking 'I was approved'" do
      before { click_button approved_btn }

      it_asks_to_confirm(has_pending_btn: true)

      example 'and clicking "confirm"' do
        expect_to_queue_card_opened_webhook_with_id(rec.id)

        click_button 'Confirm'
        sleep 1.5 # can't figure out a more elegant solution than this
        rec.reload

        # this spec fails when run late in the day when your machine's time
        # is earlier than UTC # TZFIXME
        expect(rec).to be_opened
        expect(rec.opened_on).to eq Time.zone.today
        expect(rec.called_at).to be_within(5.seconds).of(Time.zone.now)
        expect(rec.applied_on).to eq applied_on # unchanged
      end
    end

    describe "clicking 'I was denied again'" do
      before { click_button denied_btn }

      it_asks_to_confirm(has_pending_btn: true)

      example 'and clicking "confirm"' do
        expect_not_to_queue_card_opened_webhook

        click_button 'Confirm'
        sleep 1.5 # can't figure out a more elegant solution than this
        rec.reload

        expect(CardRecommendation.new(rec).status).to eq 'denied'
        expect(rec.denied_at).to eq denied_at
        expect(rec.applied_on).to eq applied_on # unchanged
        expect(rec.redenied_at).to be_within(5.seconds).of(Time.zone.now)
        expect(rec.called_at).to be_within(5.seconds).of(Time.zone.now)
      end
    end

    describe "clicking 'I'm now pending'" do
      before { click_button pending_btn }

      it_asks_to_confirm(has_pending_btn: true)

      example 'and clicking "confirm"' do
        expect_not_to_queue_card_opened_webhook

        click_button 'Confirm'
        sleep 1.5 # can't figure out a more elegant solution than this
        rec.reload

        expect(CardRecommendation.new(rec).status).to eq "denied"
        expect(rec.denied_at).to eq denied_at
        expect(rec.applied_on).to eq applied_on # unchanged
        expect(rec.called_at).to be_within(5.seconds).of(Time.zone.now)
        # doesn't set:
        expect(rec.opened_on).to be_nil
        expect(rec.redenied_at).to be_nil
      end
    end
  end
end
