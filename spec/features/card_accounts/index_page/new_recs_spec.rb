require "rails_helper"

describe "as a user viewing my cards", :js do
  include ActionView::Helpers::NumberHelper

  subject { page }

  include_context "logged in"

  let(:me) { account.owner }

  let!(:rec) do
    create(
      :card_recommendation,
      person: me,
      recommended_at: recommended_at,
    )
  end

  let(:rec_on_page) { NewCardAccountOnPage.new(rec, self) }
  let(:recommended_at) { Date.today }

  before { visit card_accounts_path }

  let(:click_confirm_btn) do
    before_click_confirm_btn
    rec_on_page.click_confirm_btn
    rec.reload
  end
  let(:before_click_confirm_btn) { nil }

  context "when I have a new card recommendation" do

    it "has buttons to apply or decline the offer", :frontend do
      expect(rec_on_page).to have_apply_btn
      expect(rec_on_page).to have_decline_btn
    end

    it "has a button to ask whether I applied", :frontend do
      expect(rec_on_page).to have_i_applied_btn
    end

    it "shows details of the card offer", :frontend do
      offer = rec.offer
      expect(rec_on_page).to have_content(
        "Spend #{number_to_currency(offer.spend)} within #{offer.days} "\
        "days to receive a bonus of "\
        "#{number_with_delimiter(offer.points_awarded)} "\
        "#{rec.card.currency.name} points"
      )
    end

    describe "the 'apply' btn" do
      it "opens the link in a new tab" do
        btn = find "a", text: "Apply"
        expect(btn[:target]).to eq "_blank"
      end
    end

    describe "clicking the 'decline' button" do
      before { rec_on_page.click_decline_btn }

      it "asks why I'm declining", :frontend do
        expect(rec_on_page).to have_decline_reason_field
      end

      it "shows a 'cancel' and a 'confirm' button", :frontend do
        expect(rec_on_page).to have_confirm_btn
        expect(rec_on_page).to have_cancel_btn
        expect(rec_on_page).to have_no_apply_btn
        expect(rec_on_page).to have_no_decline_btn
      end

      describe "submitting an empty decline reason" do
        it "shows an error message and doesn't save", :frontend do
          click_confirm_btn
          expect(rec_on_page).to have_content "Please include a message"
          expect(rec_on_page.decline_reason_wrapper[:class]).to match(/\bfield_with_errors\b/)
        end

        it "doesn't update the rec's attributes", :backend do
          expect{click_confirm_btn}.not_to change{rec.reload.attributes}
        end
      end

      describe "submitting a decline reason" do
        let(:message) { "Because I say so, bitch!" }
        before { rec_on_page.fill_in_decline_reason(with: message) }

        it "updates the card account's status to 'declined'", :backend do
          click_confirm_btn
          expect(rec.status).to eq "declined"
        end

        it "sets the 'declined at' timestamp to the current time", :backend do
          click_confirm_btn
          expect(rec.declined_at).to eq Date.today
        end

        it "shows a success message" do
          click_confirm_btn
          expect(page).to have_success_message t("card_accounts.index.declined")
        end

        context "when the card is no longer 'declinable'" do
          before do
            rec.update_attributes!(applied_at: Date.today)
            raise if rec.declinable? # sanity check
          end

          # This could happen if e.g. they have the same window open in two
          # tabs, and decline the card in one tab before clicking 'decline'
          # again in the other tab
          it "fails gracefully", :backend, :frontend do
            click_confirm_btn
            expect(current_path).to eq card_accounts_path
            expect(page).to have_info_message t("card_accounts.index.couldnt_decline")
          end
        end
      end

      describe "clicking 'cancel'" do
        before { rec_on_page.click_cancel_btn }

        it "shows the 'apply/decline' buttons again", :frontend do
          expect(rec_on_page).to have_apply_btn
          expect(rec_on_page).to have_decline_btn
        end
      end
    end # clicking 'decline'

    describe "clicking the 'I Applied' button" do
      before { rec_on_page.click_i_applied_btn }

      shared_examples "asks to confirm" do
        it "hides the current set of buttons and asks me to confirm", :frontend do
          expect(rec_on_page).to have_no_approved_btn
          expect(rec_on_page).to have_no_denied_btn
          expect(rec_on_page).to have_no_pending_btn
          expect(rec_on_page).to have_cancel_btn
          expect(rec_on_page).to have_confirm_btn
        end

        describe "and clicking 'Cancel'" do
          before { rec_on_page.click_cancel_btn }

          it "goes back a step", :frontend do
            expect(rec_on_page).to have_approved_btn
            expect(rec_on_page).to have_denied_btn
            expect(rec_on_page).to have_pending_btn
            expect(rec_on_page).to have_no_cancel_btn
            expect(rec_on_page).to have_no_confirm_btn
          end
        end
      end

      shared_examples "applied today" do
        it "sets 'applied at' to today", :backend do
          expect(rec.applied_at).to eq Date.today
        end
      end

      it "hides the 'I Applied' button", :frontend do
        expect(rec_on_page).to have_no_i_applied_btn
      end

      it "asks me for the result of the application", :frontend do
        expect(rec_on_page).to have_approved_btn
        expect(rec_on_page).to have_denied_btn
        expect(rec_on_page).to have_pending_btn
      end

      describe "clicking 'I was approved'" do
        before { rec_on_page.click_approved_btn }

        include_examples "asks to confirm"

        shared_examples "unapplyable" do
          context "when the account is no longer 'applyable'" do
            # This could happen if e.g. they've made changes in another tab
            let(:before_click_confirm_btn) do
              rec.update_attributes!(declined_at: Date.today, decline_reason: "x")
              raise if rec.openable? # sanity check
            end

            it "doesn't update anything", :backend do
              expect(rec).to be_declined
              expect(rec.opened_at).to be_nil
              expect(rec.applied_at).to be_nil
            end
          end
        end

        context "when I was recommended this card today" do
          it "shows Confirm/Cancel buttons with no datepicker", :frontend do
            expect(rec_on_page).to have_no_approved_at_field
            expect(rec_on_page).to have_confirm_btn
            expect(rec_on_page).to have_cancel_btn
          end

          describe "clicking 'Confirm'" do
            before { click_confirm_btn }

            it "sets the card account to 'open'", :backend do
              expect(rec).to be_open
            end

            it "sets 'opened at' to today", :backend do
              expect(rec.opened_at).to eq Date.today
            end

            include_examples "applied today"

            include_examples "unapplyable"
          end
        end

        context "when I was recommended this card before today" do
          let(:recommended_at) { Date.yesterday }

          it "shows a date picker and Confirm/Cancel buttons", :frontend do
            expect(rec_on_page).to have_approved_at_field
            expect(rec_on_page).to have_cancel_btn
            expect(rec_on_page).to have_confirm_btn
          end

          describe "picking a date and clicking 'Confirm'" do
            let(:date) { 5.days.ago }
            before do
              rec_on_page.set_approved_at_to(date)
              click_confirm_btn
            end

            it "sets the card account to 'opened'", :backend do
              expect(rec).to be_open
            end

            it "sets 'opened at' and 'applied at' to the chosen date", :backend do
              expect(rec.opened_at.to_date).to eq date.to_date
              expect(rec.applied_at.to_date).to eq date.to_date
            end

            include_examples "unapplyable"
          end
        end
      end

      describe "clicking 'I was denied'" do
        before { rec_on_page.click_denied_btn }

        include_examples "asks to confirm"

        context "and clicking 'Confirm'" do
          before { click_confirm_btn }

          it "marks the card as denied", :backend do
            expect(rec.status).to eq "denied"
          end

          it "sets 'denied at' and 'applied at' to today", :backend do
            expect(rec.denied_at).to eq Date.today
            expect(rec.applied_at).to eq Date.today
          end

          context "when the account is no longer 'deniable'" do
            # This could happen if e.g. they've made changes in another tab
            let(:before_click_confirm_btn) do
              rec.update_attributes!(declined_at: Date.today, decline_reason: "x")
              raise if rec.deniable? # sanity check
            end

            it "doesn't update anything", :backend do
              expect(rec).to be_declined
              expect(rec.applied_at).to be_nil
              expect(rec.denied_at).to be_nil
            end
          end
        end
      end

      describe "clicking 'I'm still waiting to hear back'" do
        before { rec_on_page.click_pending_btn }

        include_examples "asks to confirm"

        context "and clicking 'Confirm'" do
          before { click_confirm_btn }

          it "marks the card as pending", :backend do
            expect(rec.status).to eq "applied"
          end

          include_examples "applied today"

          context "when the account is no longer 'pendingable'" do
            # This could happen if e.g. they've made changes in another tab
            let(:before_click_confirm_btn) do
              rec.update_attributes!(declined_at: Date.today, decline_reason: "x")
              raise if rec.pendingable? # sanity check
            end

            it "doesn't update anything", :backend do
              expect(rec).to be_closed
              expect(rec.applied_at).to be_nil
            end
          end
        end
      end
    end

  end # when I have been recommended some cards

end
