require "rails_helper"

RSpec.describe "user cards page - nudgeable cards", :js do
  include ApplicationSurveyMacros
  include_context "logged in"

  let(:person) { account.owner }

  let(:recommended_at) { 7.days.ago.to_date }
  let(:applied_on) { 7.days.ago.to_date }
  let(:bp) { :personal }

  before do
    person.update!(eligible: true)
    @bank = Bank.all.first
    @product = create(:card_product, bank_id: @bank.id, bp: bp)
    @offer = create_offer(product: @product)
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
  let(:i_heard_back_btn) { "I heard back from #{@bank.name} by mail or email" }

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
    let(:bp) { :personal }
    it "gives me the bank's personal number" do
      expect(page).to have_content "call #{bank.name} at #{personal_no}"
      expect(page).to have_no_content business_no
    end
  end

  context "for a business card product" do
    let(:bp) { :business }
    it "gives me the bank's business number" do
      expect(page).to have_content "call #{bank.name} at #{business_no}"
      expect(page).to have_no_content personal_no
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
        expect(page).to have_no_button 'Confirm'
      end
    end

    include_examples "clicking 'cancel'"

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

        it "updates the rec's attributes", :backend do
          # this spec fails when run late in the day when your machine's time
          # is earlier than UTC # TZFIXME
          expect(rec).to be_opened
          expect(rec.opened_on).to eq Time.zone.today
          expect(rec.nudged_at).to be_within(5.seconds).of(Time.zone.now)
          expect(rec.applied_on).to eq applied_on # unchanged
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

        it "updates the rec's attributes", :backend do
          expect(CardRecommendation.new(rec).status).to eq "denied"
          expect(rec.applied_on).to eq applied_on # unchanged
          expect(rec.denied_at).to be_within(5.seconds).of(Time.zone.now)
          expect(rec.nudged_at).to be_within(5.seconds).of(Time.zone.now)
        end
      end
    end

    describe "clicking 'I'm still waiting'" do
      before { click_button pending_btn }

      include_examples "asks to confirm"

      describe "and clicking 'confirm'" do
        before do
          click_button 'Confirm'
          # FIXME can't figure out a more elegant solution than this:
          sleep 1.5
          rec.reload
        end

        it "updates the rec's attributes", :backend do
          expect(CardRecommendation.new(rec).status).to eq "applied"
          expect(rec.applied_on).to eq applied_on # unchanged
          expect(rec.nudged_at).to be_within(5.seconds).of(Time.zone.now)
        end
      end
    end
  end

  describe "clicking 'I heard back'" do
    before { click_button i_heard_back_btn }

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

    shared_examples "doesn't change applied or nudged" do
      it "doesn't change applied or set nudged", :backend do
        expect(rec.nudged_at).to be_nil
        expect(rec.applied_on).to eq applied_on
      end
    end

    it "asks for the result", :frontend do
      expect(page).to have_no_button i_called_btn(rec)
      expect(page).to have_no_button i_heard_back_btn
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
    end

    include_examples "clicking 'cancel'"

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

        it "updates the rec's attributes", :backend do
          # this spec fails when run late in the day when your machine's time
          # is earlier than UTC # TZFIXME
          expect(rec).to be_opened
          expect(rec.opened_on).to eq Time.zone.today
        end

        include_examples "doesn't change applied or nudged"
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

        it "updates the rec's attributes", :backend do
          expect(CardRecommendation.new(rec).status).to eq 'denied'
          expect(rec.denied_at).to be_within(5.seconds).of(Time.zone.now)
        end

        include_examples "doesn't change applied or nudged"
      end
    end
  end
end
