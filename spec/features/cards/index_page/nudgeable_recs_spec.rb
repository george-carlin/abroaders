require "rails_helper"

RSpec.describe "user cards page - nudgeable cards", :js do
  include ApplicationSurveyMacros
  include ZapierWebhooksMacros

  include_context "logged in"

  let(:person) { account.owner }

  let(:recommended_at) { 7.days.ago.to_date }
  let(:applied_on) { 7.days.ago.to_date }
  let(:personal) { true }

  before do
    person.update!(eligible: true)
    @bank = Bank.all.first
    @product = create(:card_product, bank_id: @bank.id, personal: personal)
    @offer = create_offer(card_product: @product)
    @rec = create_card_recommendation(person_id: person.id, offer_id: @offer.id)
    @rec.update!(recommended_at: recommended_at, applied_on: applied_on)
    visit cards_path
  end

  let(:rec)  { @rec }
  let(:bank) { @bank }
  let(:personal_no) { @bank.personal_phone }
  let(:business_no) { @bank.business_phone }

  let(:approved_btn) { "My application was approved" }
  let(:denied_btn)   { "My application was denied" }
  let(:pending_btn)  { "I'm still waiting to hear back" }

  def i_heard_back_btn
    super(rec)
  end

  shared_examples "clicking 'cancel'" do
    describe "and clicking 'cancel'" do
      before { click_button 'Cancel' }

      it "goes back to the 'I called'/'I heard back' buttons", :frontend do
        expect(page).to have_button i_called_btn(rec)
        expect(page).to have_button i_heard_back_btn
        expect(page).to have_no_button approved_btn
        expect(page).to have_no_button denied_btn
        expect(page).to have_no_button pending_btn
      end
    end
  end

  example "nudgeable rec on page", :frontend do
    # has buttons:
    expect(page).to have_button i_called_btn(rec)
    expect(page).to have_button i_heard_back_btn
    expect(page).to have_no_find_card_btn(rec)
    expect(page).to have_no_button decline_btn
    expect(page).to have_no_button i_applied_btn
    # it encourages the user to call the bank:
    expect(page).to have_content "We strongly recommend that you call #{bank.name}"
    expect(page).to have_content(
      "You’re more than twice as likely to get approved if you call #{bank.name} "\
      "than if you wait for them to send your decision in the mail",
    )
  end

  context "for a personal card product" do
    let(:personal) { true }
    it "gives me the bank's personal number" do
      expect(page).to have_content "call #{bank.name} at #{personal_no}"
      expect(page).to have_no_content business_no
    end
  end

  context "for a business card product" do
    let(:personal) { false }
    it "gives me the bank's business number" do
      expect(page).to have_content "call #{bank.name} at #{business_no}"
      expect(page).to have_no_content personal_no
    end
  end

  def self.it_asks_to_confirm(has_pending_btn:)
    example 'it can be confirmed/canceled' do
      expect(page).to have_no_button approved_btn
      expect(page).to have_no_button denied_btn
      expect(page).to have_no_button pending_btn
      expect(page).to have_button 'Cancel'
      expect(page).to have_button 'Confirm'
      # going back
      click_button 'Cancel'
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
      expect(page).to has_pending_btn ? have_button(pending_btn) : have_no_button(pending_btn)
      expect(page).to have_no_button 'Confirm'
    end
  end

  describe "clicking 'I called'" do
    before { click_button i_called_btn(rec) }

    include_examples "clicking 'cancel'"

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
        click_button 'Confirm'
        sleep 1.5 # can't figure out a more elegant solution than this
        rec.reload

        # this spec fails when run late in the day when your machine's time
        # is earlier than UTC # TZFIXME
        expect(rec).to be_opened
        expect(rec.opened_on).to eq Time.zone.today
        expect(rec.nudged_at).to be_within(5.seconds).of(Time.zone.now)
        expect(rec.applied_on).to eq applied_on # unchanged
      end
    end

    describe "clicking 'I was denied'" do
      before { click_button denied_btn }

      it_asks_to_confirm(has_pending_btn: true)

      example 'and clicking "confirm"' do
        expect_not_to_queue_card_opened_webhook

        click_button 'Confirm'
        sleep 1.5 # can't figure out a more elegant solution than this
        rec.reload

        expect(CardRecommendation.new(rec).status).to eq "denied"
        expect(rec.applied_on).to eq applied_on # unchanged
        expect(rec.denied_at).to be_within(5.seconds).of(Time.zone.now)
        expect(rec.nudged_at).to be_within(5.seconds).of(Time.zone.now)
      end
    end

    describe 'clicking "I\'m still waiting"' do
      before { click_button pending_btn }

      it_asks_to_confirm(has_pending_btn: true)

      example 'and clicking "confirm"' do
        expect_not_to_queue_card_opened_webhook

        click_button 'Confirm'
        sleep 1.5 # can't figure out a more elegant solution than this
        rec.reload

        expect(CardRecommendation.new(rec).status).to eq 'applied'
        expect(rec.applied_on).to eq applied_on # unchanged
        expect(rec.nudged_at).to be_within(5.seconds).of(Time.zone.now)
      end
    end
  end

  describe "clicking 'I heard back'" do
    before { click_button i_heard_back_btn }

    it "asks for the result", :frontend do
      expect(page).to have_no_button i_called_btn(rec)
      expect(page).to have_no_button i_heard_back_btn
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
    end

    include_examples "clicking 'cancel'"

    describe "clicking 'I was approved'" do
      before { click_button approved_btn }

      it_asks_to_confirm(has_pending_btn: false)

      example 'and clicking "confirm"' do
        click_button 'Confirm'
        sleep 1.5 # can't figure out a more elegant solution than this
        rec.reload

        # this spec fails when run late in the day when your machine's time
        # is earlier than UTC # TZFIXME
        expect(rec).to be_opened
        expect(rec.opened_on).to eq Time.zone.today
        expect(rec.nudged_at).to be_nil
        expect(rec.applied_on).to eq applied_on
      end
    end

    describe "clicking 'I was denied'" do
      before { click_button denied_btn }

      it_asks_to_confirm(has_pending_btn: false)

      example 'and clicking "confirm"' do
        click_button 'Confirm'
        sleep 1.5 # can't figure out a more elegant solution than this
        rec.reload

        expect(CardRecommendation.new(rec).status).to eq 'denied'
        expect(rec.denied_at).to be_within(5.seconds).of(Time.zone.now)
        expect(rec.nudged_at).to be_nil
        expect(rec.applied_on).to eq applied_on
      end
    end
  end
end
