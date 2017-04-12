require "rails_helper"

RSpec.describe "user cards page - callable cards", :js do
  include ApplicationSurveyMacros
  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }

  let(:recommended_at) { 7.days.ago.to_date }
  let(:applied_on) { 7.days.ago.to_date }
  let(:denied_at)  { 5.days.ago.to_date }
  let(:bp) { :personal }

  # override variables set by ApplicationSurveyMacros:
  let(:approved_btn) { 'I was approved after reconsideration' }
  let(:denied_btn) { 'My application is still denied' }
  let(:pending_btn) { "I'm being reconsidered, but waiting to hear back about whether it was successful" }

  before do
    person.update!(eligible: true)
    login_as_account(account)
    @bank    = create(:bank, name: "Chase")
    @product = create(:card_product, bank_id: @bank.id, bp: bp)
    @offer = create_offer(product: @product)
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
    let(:bp) { :personal }
    it "gives me the bank's personal number" do
      expect(page).to have_content "call #{@bank.name} at #{personal_phone}"
      expect(page).to have_no_content business_phone
    end
  end

  context "for a business card product" do
    let(:bp) { :business }
    it "gives me the bank's business number" do
      expect(page).to have_content "call #{@bank.name} at #{business_phone}"
      expect(page).to have_no_content personal_phone
    end
  end

  describe "clicking 'I called'" do
    before { click_button i_called_btn(rec) }

    shared_examples "asks to confirm" do
      it "asks to confirm", :frontend do
        expect(page).to have_no_button approved_btn
        expect(page).to have_no_button denied_btn
        expect(page).to have_no_button pending_btn
        expect(page).to have_button 'Cancel'
        expect(page).to have_button 'Confirm'
        # going back
        click_button 'Cancel'
        expect(page).to have_button approved_btn
        expect(page).to have_button denied_btn
        expect(page).to have_button pending_btn
        expect(page).to have_no_button 'Cancel'
        expect(page).to have_no_button 'Confirm'
      end
    end

    it "asks for the result", :frontend do
      expect(page).to have_no_button i_called_btn(rec)
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
      expect(page).to have_button pending_btn
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
          expect(rec.opened_on).to eq Time.zone.today
          expect(rec.called_at).to be_within(5.seconds).of(Time.zone.now)
          expect(rec.applied_on).to eq applied_on # unchanged
        end
      end
    end

    describe "clicking 'I was denied again'" do
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
          expect(rec.status).to eq "denied"
          expect(rec.denied_at).to eq denied_at
          expect(rec.applied_on).to eq applied_on # unchanged
          expect(rec.redenied_at).to be_within(5.seconds).of(Time.zone.now)
          expect(rec.called_at).to be_within(5.seconds).of(Time.zone.now)
        end
      end
    end

    describe "clicking 'I'm now pending'" do
      before { click_button pending_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          click_button 'Confirm'
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the card account's attributes", :backend do
          expect(rec.status).to eq "denied"
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
end
