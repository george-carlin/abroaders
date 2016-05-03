require "rails_helper"

describe "as a user viewing my cards" do
  include ActionView::Helpers::NumberHelper
  include CardAccountsIndexPageMacros

  subject { page }

  include_context "logged in"

  let(:me) { account.main_passenger }
  let(:partner) { account.companion }

  before do
    create(:companion, account: account) if has_partner
    extra_setup
    visit card_accounts_path
  end

  let(:extra_setup) { nil }
  let(:has_partner) { false }

  let(:card_recommendations_selector)    { "#card_recommendations" }
  let(:main_recommendations_selector)    { "#main_person_card_recommendations" }
  let(:partner_recommendations_selector) { "#partner_card_recommendations" }

  let(:pending_recs_notice) do
    "The Abroaders team is hand selecting the ideal rewards cards based "\
    "on your current points, travel plans and spending. We’ll let you "\
    "know as soon as the card recommendations are ready to view."
  end

  context "when I have not been recommended any cards" do
    it "tells me that recs are coming" do
      is_expected.to have_content pending_recs_notice
    end
  end

  context "when I have been recommended some cards" do
    let(:extra_setup) do
      @recs = create_list(:card_recommendation, 2, person: me)
    end

    it "lists them all" do
      within main_recommendations_selector do
        @recs.each do |recommendation|
          is_expected.to have_card_account(recommendation)
          within card_account_selector(recommendation) do
            is_expected.to have_content recommendation.card_name
            is_expected.to have_content recommendation.card_bank_name
          end
        end
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

    describe "each card recommendation" do
      it "shows details of its card offer" do
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

      it "has buttons to apply or decline " do
        @recs.each do |recommendation|
          is_expected.to have_apply_btn(recommendation)
          is_expected.to have_decline_btn(recommendation)
        end
      end
    end

    # Possibly see https://github.com/teampoltergeist/poltergeist/commit/57f039ec17c6f5786f18d2a43266f79fac57f554
    pending "the 'apply' btn opens in a new tab"

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

  context "when I have a partner" do
    let(:has_partner) { true }

    context "and neither of us have been recommended any cards" do
      it "tells me that recs are coming" do
        is_expected.to have_content pending_recs_notice
      end
    end

    context "and my partner has been recommended some cards" do
      let(:extra_setup) do
        @recs = create_list(:card_recommendation, 2, person: partner)
      end

      it "lists them all" do
        within partner_recommendations_selector do
          @recs.each do |recommendation|
            is_expected.to have_card_account(recommendation)
            within card_account_selector(recommendation) do
              is_expected.to have_content recommendation.card_name
              is_expected.to have_content recommendation.card_bank_name
            end
          end
        end
      end
    end
  end
end
