require "rails_helper"

describe "as a user viewing my cards" do
  include ActionView::Helpers::NumberHelper
  include CardAccountsIndexPageMacros

  subject { page }

  include_context "logged in"

  let(:me) { account.main_passenger }
  let(:partner) { account.companion }

  before do
    @cards = create_list(:card, 5)
    extra_setup
    visit card_accounts_path
  end

  let(:extra_setup) { nil }

  let(:card_recommendations_selector) { "#card_recommendations" }

  context "when I didn't add any cards in the onboarding survey" do
    before { raise if me.card_accounts.from_survey.any? } # Sanity check

    it "doesn't have a section for them" do
      is_expected.to have_survey_cards_header(false)
      is_expected.to have_no_selector survey_cards_section
    end
  end

  context "when I added cards in the onboarding survey" do
    let(:extra_setup) do
      @open_account   = create(:open_survey_card_account,   person: me, card: @cards[0])
      @closed_account = create(:closed_survey_card_account, person: me, card: @cards[1])
    end

    it "has a section for them" do
      is_expected.to have_selector "h2", "Other Cards"
      is_expected.to have_selector "#card_accounts_from_survey"
    end

    it "lists them" do
      within "#card_accounts_from_survey" do
        is_expected.to have_selector card_account_selector(@open_account)
        is_expected.to have_selector card_account_selector(@closed_account)
      end

      within card_account_selector(@open_account) do
        is_expected.to have_content "Card Name: #{@cards[0].name}"
        is_expected.to have_content "Bank: #{@cards[0].bank_name}"
        is_expected.to have_content "Open"
        is_expected.to have_content @open_account.opened_at.strftime("%b %Y")
        is_expected.not_to have_content "Closed"
      end

      within card_account_selector(@closed_account) do
        is_expected.to have_content "Card Name: #{@cards[1].name}"
        is_expected.to have_content "Bank: #{@cards[1].bank_name}"
        is_expected.to have_content "Closed"
        is_expected.to have_content @closed_account.opened_at.strftime("%b %Y")
        is_expected.to have_content @closed_account.closed_at.strftime("%b %Y")
      end
    end

    it "doesn't have apply/decline btns for them" do
      is_expected.to have_no_apply_btn(@open_account)
      is_expected.to have_no_decline_btn(@open_account)
      is_expected.to have_no_apply_btn(@closed_account)
      is_expected.to have_no_decline_btn(@closed_account)
    end
  end

  context "when I have a companion" do
    pending
  end


  context "when I have been recommended some cards" do
    let(:extra_setup) do
      @recs = create_list(:card_recommendation, 2, person: me)
    end

    it "lists them all" do
      within card_recommendations_selector do
        @recs.each do |recommendation|
          is_expected.to have_card_account(recommendation)
          within card_account_selector(recommendation) do
            is_expected.to have_content recommendation.card_name
            is_expected.to have_content recommendation.card_bank_name
          end
        end
      end
    end

    it "shows details of the relevant card offers" do
      @recs.each do |recommendation|
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

    it "has buttons to apply for or decline each recommendation" do
      @recs.each do |recommendation|
        is_expected.to have_apply_btn(recommendation)
        is_expected.to have_decline_btn(recommendation)
      end
    end

    describe "clicking the 'decline' button", :js do
      let(:rec) { @recs[0] }
      before { find(decline_btn(rec)).click }

      let(:decline_reason_field) { "card_account_#{rec.id}_decline_reason" }

      it "shows a text field asking me why I'm declining" do
        is_expected.to have_field decline_reason_field
      end

      let(:cancel_btn)  { "#card_recommendation_#{rec.id}_cancel_decline_btn" }
      let(:confirm_btn) { "#card_recommendation_#{rec.id}_confirm_decline_btn" }
      let(:confirm) do
        within(card_account_selector(rec)) { click_button "Confirm" }
      end

      it "hides the 'apply/decline' buttons" do
        is_expected.to have_no_apply_btn(rec)
        is_expected.to have_no_decline_btn(rec)
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
          field_wrapper = find("##{decline_reason_field}").find(:xpath, '..')
          expect(field_wrapper[:class]).to match(/\bfield_with_errors\b/)
        end
      end

      describe "filling in the field and clicking 'confirm'" do
        let(:message) { "Because I say so, bitch!" }
        before { fill_in decline_reason_field, with: message }

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
            pending
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
          is_expected.to have_apply_btn(rec)
          is_expected.to have_decline_btn(rec)
        end

        it "doesn't change the card's status" do
          expect(rec.reload).to be_recommended
        end
      end
    end

    # Possibly see https://github.com/teampoltergeist/poltergeist/commit/57f039ec17c6f5786f18d2a43266f79fac57f554
    pending "the 'apply' btn opens in a new tab"
  end


  context "when I have clicked 'Apply' on a recommendation" do
    let(:extra_setup) { @rec = create(:clicked_card_recommendation, person: me) }
    let(:rec)   { @rec }
    let(:offer) { rec.offer }

    it "still shows the card under 'recommendations'" do
      within card_recommendations_selector do
        is_expected.to have_card_account(rec)
        within card_account_selector(rec) do
          # Card details:
          is_expected.to have_content rec.card_name
          is_expected.to have_content rec.card_bank_name
          # Offer details:
          is_expected.to have_content(
            "Spend #{number_to_currency(offer.spend)} within #{offer.days} "\
            "days to receive a bonus of "\
            "#{number_with_delimiter(offer.points_awarded)} "\
            "#{rec.card_currency.name} points"
          )
          # Apply/decline btns:
          is_expected.to have_apply_btn(rec)
          is_expected.to have_decline_btn(rec)
        end
      end
    end

    it "asks me whether I applied etc"
  end
end
