require "rails_helper"

describe "as a user viewing my card recommendations", :js do
  include ActionView::Helpers::NumberHelper
  subject { page }

  include_context "logged in"

  before do
    extra_setup
    visit card_accounts_path
  end

  let(:extra_setup) { nil }

  # TODO - right now the page only shows me the main passenger's recommendations.
  # Needs some serious rethinking

  let(:passenger) { account.main_passenger }

  context "when there are cards I added in the onboarding survey" do
    let(:extra_setup) do
      @card_accounts = create_list(
        :card_account,
        2,
        status: :unknown,
        passenger: passenger
      )
    end

    it "lists them all" do
      within "#unknown_card_accounts" do
        @card_accounts.each do |account|
          is_expected.to have_card_account(account)
          within card_account_selector(account) do
            is_expected.to have_content account.card_name
            is_expected.to have_content account.card_bank_name
          end
        end
      end
    end
  end

  context "when I have been recommended some cards" do
    let(:extra_setup) do
      @recommendations = create_list(:card_rec, 2, passenger: passenger)
    end

    it "lists them all" do
      within "#recommended_card_accounts" do
        @recommendations.each do |recommendation|
          is_expected.to have_card_account(recommendation)
          within card_account_selector(recommendation) do
            is_expected.to have_content recommendation.card_name
            is_expected.to have_content recommendation.card_bank_name
          end
        end
      end
    end

    it "shows details of the relevant card offers" do
      @recommendations.each do |recommendation|
        offer = recommendation.offer
        within card_account_selector(recommendation) do
          is_expected.to have_content(
            "Spend #{number_to_currency(offer.spend)} within #{offer.days} "\
            "days to receive a bonus of "\
            "#{number_with_delimiter(offer.points_awarded)} "\
            "#{recommendation.card_currency.name} points"
          )
        end
      end
    end

    it "has a button to decline each recommendation" do
      @recommendations.each do |recommendation|
        is_expected.to have_selector(
          decline_rec_btn(recommendation), text: "No Thanks"
        )
      end
    end

    it "has a link to apply for each recommendation" do
      @recommendations.each do |rec|
        is_expected.to have_link "Apply", href: apply_card_account_path(rec)
      end
    end

    describe "clicking the 'decline' button", :js do
      let(:rec) { @recommendations[0] }
      before { find(decline_rec_btn(rec)).click }

      it "shows a text field asking me why I'm declining" do
        is_expected.to have_field :card_account_decline_reason
      end

      let(:cancel_btn)  { "#card_account_#{rec.id}_cancel_decline_btn" }
      let(:confirm_btn) { "#card_account_#{rec.id}_confirm_decline_btn" }
      let(:confirm) do
        within(card_account_selector(rec)) { click_button "Confirm" }
      end

      it "hides the 'apply/decline' buttons" do
        is_expected.to have_no_link "Apply", href: apply_card_account_path(rec)
        is_expected.to have_no_selector decline_rec_btn(rec), text: "No Thanks"
      end

      it "shows a 'cancel' and a 'confirm' button" do
        within card_account_selector(rec) do
          is_expected.to have_selector cancel_btn, text: "Cancel"
          is_expected.to have_selector confirm_btn, text: "Confirm"
        end
      end

      describe "submitting an empty text field" do
        it "shows an error message and doesn't save" do
          expect{confirm}.not_to change{rec.reload.attributes}
          expect(page).to have_content "Please include a message"
        end
      end

      describe "filling in the field and clicking 'confirm'" do
        let(:message) { "Because I say so, bitch!" }
        before { fill_in :card_account_decline_reason, with: message }

        let(:submit) do
          confirm
          rec.reload
        end

        it "updates the card account's status to 'declined'" do
          submit
          expect(rec).to be_declined
        end

        it "sets the 'declined at' timestamp to the current time" do
          submit
          expect(rec.declined_at).to be_within(5.seconds).of Time.now
        end

        context "when the card is no longer 'declinable'" do
          before { rec.applied! }

          # This could happen if e.g. they have the same window open in two
          # tabs, and decline the card in one tab before clicking 'decline'
          # again in the other tab
          it "fails gracefully" do
            submit
            expect(current_path).to eq card_accounts_path
            expect(page).to have_info_message text: t("card_accounts.index.couldnt_decline")
          end
        end
      end

      describe "clicking 'cancel'" do
        before do
          within card_account_selector(rec) do
            click_button "Cancel"
          end
        end

        it "shows the 'apply/decline' buttons again" do
          is_expected.to have_link "Apply", href: apply_card_account_path(rec)
          is_expected.to have_selector decline_rec_btn(rec), text: "No Thanks"
        end

        it "doesn't change the card's status" do
          expect(rec.reload).to be_recommended
        end
      end
    end

    describe "clicking 'Apply'", :js do
      let(:rec) { @recommendations[0] }
      before do
        within card_account_selector(rec) do
          click_link _t("have_applied")
        end
      end

      # Possibly see https://github.com/teampoltergeist/poltergeist/commit/57f039ec17c6f5786f18d2a43266f79fac57f554
      it "opens the redirect page in a new tab"

      it "prevents me from clicking 'Apply' a second time"
      # TODO we need to do something here, because 'Apply' opens a window
      # in a new tab, meaning that the tab with the Apply/Decline buttons
      # will still be open, but the buttons won't work anymore (but currently
      # they raise a noisy error). This needs to be made more user-friendly,
      # but let's wait until we've figured out exactly how we're going
      # to display recommendations that have already been applied/declined
      # on card_accounts_path
    end

    describe "opening the 'apply' page" do
      let(:rec) { @recommendations[0] }
      before { visit apply_card_account_path(rec) }

      # TODO How can we test this?
      it "redirects to the bank's page after a delay"

      it "saves the card status as 'applied'" do
        expect(rec.reload.status).to eq "applied"
      end

      it "sets the 'applied at' timestamp to the current time" do
        expect(rec.reload.applied_at).to be_within(5.seconds).of Time.now
      end

      context "when the recommendation is already 'applied'" do
        # Page should still work, because they might have clicked the 'Apply'
        # button but not actually applied
        let(:rec) do
          r = @recommendations[0]
          r.update_attributes!(status: :applied, applied_at: 5.days.ago)
          r
        end

        it "updates the 'applied at' timestamp to the current time" do
          expect(rec.reload.applied_at).to be_within(5.seconds).of Time.now
        end
      end
    end
  end

  describe "when I have applied for a card" do
    let(:extra_setup) do
      @offer = create(:card_offer)
      @card  = @offer.card
      @card_account = create(
        :card_account,
        passenger:  passenger,
        status:    :applied,
        applied_at: applied_at,
        offer: @offer,
        card: nil
      )
    end
    let(:applied_at) { 5.days.ago }
    let(:card_account) { @card_account }
    let(:offer) { @offer }
    let(:card)  { @card }

    it "displays the card" do
      is_expected.to have_card_account(card_account)
    end

    it "says when I applied" do
      within card_account_selector(card_account) do
        is_expected.to have_content "You indicated on #{applied_at.strftime("%D")} that you had applied for this card"
      end
    end

    it "asks me if I have been approved" do
      within card_account_selector(card_account) do
        is_expected.to have_content "When you hear back from the bank, tell us whether or not you were approved for the card"
      end
    end

    describe "clicking 'I have been approved'", :js do
      before { click_button "I have been approved" }

      it "asks me to confirm" do
        is_expected.to have_no_button "I have been approved"
        is_expected.to have_button "Cancel"
        is_expected.to have_button "Confirm"
      end

      describe "clicking 'confirm'" do
        before { pending; click_button "Confirm" }

        context "if I applied today" do
          it "updates card status to 'open'" do
            expect(card_account.reload).to be_open
          end

          it "saves 'opened at' to today" do
            expect(card_account.opened_at.to_date).to eq Date.today
          end
        end

        context "when I applied more than one day ago" do
          it "shows a datepicker asking me when I was approved"

          context "selecting a date and submitting" do
            it "updates card status to 'open'"
            it "saves 'opened at' to today"
          end
        end
      end

      describe "clicking 'cancel'" do
        before { click_button "Cancel" }

        it "hides the confirm/cancel buttons" do
          is_expected.to have_button "I have been approved"
          is_expected.to have_no_button "Cancel"
          is_expected.to have_no_button "Confirm"
        end
      end
    end

    describe "clicking 'I have not yet been approved'", :js do
      it "asks if I was denied, or if I haven't heard back yet"

      describe "saying I was denied" do
        it "asks me to confirm"

        describe "and confirming" do
          it "sets card account status to 'denied'"
          it "sets 'denied at' timestamp to the current time"
          it "tells me to call the bank"
        end

        describe "and clicking 'cancel'" do
          it "shows the 'denied/pending' buttons again"
        end
      end

      describe "saying I'm still waiting to hear back" do
        it "asks me to confirm"

        describe "and confirming" do
          it "sets card account status to 'pending decision'"

          it "tells me to call the bank"
        end

        describe "and clicking 'cancel'" do
          it "shows the 'approved/not approved' buttons again"
        end
      end
    end # clicking 'I have not yet been approved'
  end # when there is a card with status 'applied'

  describe "when I have declined to apply for a card" do
  end

  describe "when I am waiting to hear back about a card" do
  end

  describe "when I have an open card" do
    it "displays bonus challenge information"
  end

  #    it "shows accepted/denied/pending buttons" do
  #      within card_account_selector(rec) do
  #        is_expected.to have_button _t("was_accepted")
  #        is_expected.to have_button _t("was_denied")
  #        is_expected.to have_link _t("still_waiting")
  #      end
  #    end

  #    it "has a back button" do
  #      within card_account_selector(rec) do
  #        is_expected.to have_link "Back"
  #      end
  #    end

  #    describe "clicking the 'back' button" do
  #      before do
  #        within card_account_selector(rec) do
  #          click_link "Back"
  #        end
  #      end
  #      it "shows the apply/decline/applied buttons again" do
  #        within card_account_selector(rec) do
  #          is_expected.to have_selector decline_rec_btn(rec)
  #          is_expected.to have_link "Apply"
  #          is_expected.to have_link _t("have_applied")
  #        end
  #      end

  #      it "hides the accepted/denied/pending buttons" do
  #        within card_account_selector(rec) do
  #          is_expected.to have_no_button _t("was_accepted")
  #          is_expected.to have_no_button _t("was_denied")
  #          is_expected.to have_no_link _t("still_waiting")
  #        end
  #      end
  #    end

  #    describe "clicking 'accepted'" do
  #      before { click_button _t("was_accepted") }
  #      it "asks *when* the application was accepted"
  #      it "updates the card account's status to 'open'" do
  #        rec.reload
  #        expect(rec.status).to eq "open"
  #        expect(rec).not_to be_reconsidered
  #      end
  #    end

  #    describe "clicking 'denied'" do
  #      before { click_button _t("was_denied") }
  #      it "updates the account's status to 'denied'" do
  #        rec.reload
  #        expect(rec.status).to eq "denied"
  #        expect(rec).not_to be_reconsidered
  #      end
  #    end

  #    describe "clicking 'pending'" do
  #      before { click_link _t("still_waiting") }

  #      it "tells me to come back when I know the result of the app." do
  #        rec.reload
  #        expect(current_path).to eq card_accounts_path
  #        expect(rec.status).to eq "recommended"
  #        expect(rec).not_to be_reconsidered
  #        should have_content _t("application_pending")
  #        within card_account_selector(rec) do
  #          is_expected.to have_no_selector decline_rec_btn(rec)
  #          is_expected.to have_no_link "Apply"
  #          is_expected.to have_no_link _t("have_applied")
  #          is_expected.to have_no_button _t("was_accepted")
  #          is_expected.to have_no_button _t("was_denied")
  #          is_expected.to have_no_link _t("still_waiting")
  #        end
  #      end
  #    end
  #  end
  #end


  def card_account_selector(card_account)
    "##{dom_id(card_account)}"
  end

  def have_card_account(card_account)
    have_selector card_account_selector(card_account)
  end

  def decline_rec_btn(recommendation)
    "#card_account_#{recommendation.id}_decline_btn"
  end

  def applied_for_rec_btn(recommendation)
    "#card_account_#{recommendation.id}_applied_btn"
  end

  # Shortcut for the translations which are relevant to the index page
  def _t(key)
    t("card_accounts.index.#{key}")
  end

end
