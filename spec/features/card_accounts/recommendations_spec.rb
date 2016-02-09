require "rails_helper"

describe "as a user viewing my card recommendations", js: true do
  include ActionView::Helpers::NumberHelper
  subject { page }

  include_context "logged in"

  before do
    extra_setup
    visit card_accounts_path
  end

  let(:extra_setup) { nil }

  context "when I have been recommended some cards" do
    let(:extra_setup) do
      @recommendations = create_list(:card_rec, 2, user: user)
    end

    it "lists them all" do
      @recommendations.each do |recommendation|
        is_expected.to have_card_account(recommendation)
        within card_account_selector(recommendation) do
          is_expected.to have_content recommendation.card_name
          is_expected.to have_content recommendation.card_bank_name
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
            "#{recommendation.card_currency} points"
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

    describe "clicking the 'decline' button", js: true do
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
        is_expected.not_to have_link "Apply", href: apply_card_account_path(rec)
        is_expected.not_to have_selector decline_rec_btn(rec), text: "No Thanks"
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

      describe "filling in the field and clicking 'confirm" do
        let(:message) { "Because I say so, bitch!" }
        before do
          fill_in :card_account_decline_reason, with: message
          confirm
          rec.reload
        end

        it "updates the account's status to 'declined'" do
          expect(rec).to be_declined
        end

        it "sets the 'declined at' timestamp to the current time" do
          expect(rec.declined_at).to be_within(5.seconds).of Time.now
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

    describe "clicking 'Apply'", js: true do
      let(:rec) { @recommendations[0] }
      before do
        within card_account_selector(rec) do
          click_link _t("have_applied")
        end
      end

      # Possibly see https://github.com/teampoltergeist/poltergeist/commit/57f039ec17c6f5786f18d2a43266f79fac57f554
      it "opens the redirect page in a new tab"
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
      @account = create(
        :card_account,
        user: user,
        status: :applied,
        applied_at: applied_at
      )
    end
    let(:applied_at) { 5.minutes.ago }

    it "asks me if I have been approved"

    describe "clicking 'I have been approved'", js: true do
      it "asks me to confirm"

      describe "clicking 'confirm'" do
        context "if I applied today" do
          it "updates card status to 'open'"
          it "saves 'opened at' to today"
        end

        context "when I applied more than one day ago" do
          it "shows a datepicker asking me when I was approved"

          context "selecting a date and submitting" do
            it "updates card status to 'open'"
            it "saves 'opened at' to today"
          end
        end
      end
    end

    describe "clicking 'I have not yet been approved'", js: true do
      it "asks if I was denied, or if I haven't heard back yet"

      describe "saying I was denied" do
        it "asks me to confirm"

        describe "and confirming" do
          it "sets account status to 'denied'"
          it "sets 'denied at' timestamp to the current time"
          it "tells me to call the bank"
        end

        describe "and clicking 'cancel" do
          it "shows the 'denied/pending' buttons again"
        end
      end

      describe "saying I'm still waiting to hear back" do
        it "asks me to confirm"

        describe "and confirming" do
          it "sets account status to 'pending decision'"

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
  #          is_expected.not_to have_button _t("was_accepted")
  #          is_expected.not_to have_button _t("was_denied")
  #          is_expected.not_to have_link _t("still_waiting")
  #        end
  #      end
  #    end

  #    describe "clicking 'accepted'" do
  #      before { click_button _t("was_accepted") }
  #      it "asks *when* the application was accepted"
  #      it "updates the account's status to 'open'" do
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
  #          is_expected.not_to have_selector decline_rec_btn(rec)
  #          is_expected.not_to have_link "Apply"
  #          is_expected.not_to have_link _t("have_applied")
  #          is_expected.not_to have_button _t("was_accepted")
  #          is_expected.not_to have_button _t("was_denied")
  #          is_expected.not_to have_link _t("still_waiting")
  #        end
  #      end
  #    end
  #  end
  #end


  def card_account_selector(account)
    "##{dom_id(account)}"
  end

  def have_card_account(account)
    have_selector card_account_selector(account)
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
