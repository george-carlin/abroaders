require "rails_helper"

describe "cards index page - new recommendation", :js do
  include ActionView::Helpers::NumberHelper

  include_context "logged in"

  let(:person) { account.owner }

  let!(:rec) do
    create(
      :card_recommendation,
      person: person,
      recommended_at: recommended_at,
    )
  end

  let(:rec_on_page) { NewCardAccountOnPage.new(rec, self) }
  let(:recommended_at) { Date.today }

  before do
    person.update!(eligible: true)
    visit card_accounts_path
  end

  let(:click_confirm_btn) do
    before_click_confirm_btn
    rec_on_page.click_confirm_btn
    # FIXME can't figure out a more elegant solution than this:
    sleep 1.5
    rec.reload
  end
  let(:before_click_confirm_btn) { nil }

  example "new recommendation on page", :frontend do
    expect(rec_on_page).to have_apply_btn
    expect(rec_on_page).to have_decline_btn
    expect(rec_on_page).to have_i_applied_btn

    offer = rec.offer
    expect(rec_on_page).to have_content(
      "Spend #{number_to_currency(offer.spend)} within #{offer.days} "\
      "days to receive a bonus of "\
      "#{number_with_delimiter(offer.points_awarded)} "\
      "#{rec.card.currency.name} points",
    )
  end

  specify "'apply' btn opens the link in a new tab" do
    btn = find "a", text: "Apply"
    expect(btn[:target]).to eq "_blank"
  end

  example "clicking the 'decline button" do
    rec_on_page.click_decline_btn
    expect(rec_on_page).to have_decline_reason_field
    expect(rec_on_page).to have_confirm_btn
    expect(rec_on_page).to have_cancel_btn
    expect(rec_on_page).to have_no_apply_btn
    expect(rec_on_page).to have_no_decline_btn

    # clicking 'cancel' shows the first set of buttons again:
    rec_on_page.click_cancel_btn
    expect(rec_on_page).to have_apply_btn
    expect(rec_on_page).to have_decline_btn
  end

  example "submitting an empty decline reason" do
    rec_on_page.click_decline_btn
    expect { click_confirm_btn }.not_to change { rec.reload.attributes }
    # shows an error message and doesn't save:
    expect(rec_on_page).to have_content "Please include a message"
    expect(rec_on_page.decline_reason_wrapper[:class]).to match(/\bfield_with_errors\b/)
  end

  example "declining a recommendation" do
    rec_on_page.click_decline_btn
    message = "Because I say so, bitch!"
    rec_on_page.fill_in_decline_reason(with: message)
    rec_on_page.click_confirm_btn
    rec.reload
    # updates the attributes:
    expect(rec.status).to eq "declined"
    expect(rec.declined_at).to eq Date.today
    expect(page).to have_success_message t("card_accounts.index.declined")
  end

  example "trying to decline a rec that's already declined" do
    rec_on_page.click_decline_btn
    message = "Because I say so, bitch!"
    rec_on_page.fill_in_decline_reason(with: message)

    # This could happen if e.g. they have the same window open in two
    # tabs, and decline the card in one tab before clicking 'decline'
    # again in the other tab. It should fail gracefully:
    rec.update_attributes!(applied_at: Date.today)
    raise if rec.declinable? # sanity check
    rec_on_page.click_confirm_btn

    expect(current_path).to eq card_accounts_path
    expect(page).to have_info_message t("card_accounts.index.couldnt_decline")
  end

  example "clicking the 'I Applied' button" do
    rec_on_page.click_i_applied_btn
    expect(rec_on_page).to have_no_i_applied_btn
    expect(rec_on_page).to have_approved_btn
    expect(rec_on_page).to have_denied_btn
    expect(rec_on_page).to have_pending_btn
  end

  describe "clicking the 'I Applied' button" do
    before { rec_on_page.click_i_applied_btn }

    shared_examples "asks to confirm" do
      it "hides the current set of buttons and asks to confirm", :frontend do
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

          it "updates the rec's attributes", :backend do
            expect(rec).to be_open
            expect(rec.opened_at).to eq Date.today
            expect(rec.applied_at).to eq Date.today
          end

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

        specify "card attributes are updated correctly" do
          expect(page).to have_content "We strongly recommend"
          expect(rec.status).to eq "denied"
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

        it "updates the card's attributes", :backend do
          expect(rec.status).to eq "applied"
          expect(rec.applied_at).to eq Date.today
        end

        context "when the account is no longer 'pendingable'" do
          # This could happen if e.g. they've made changes in another tab
          let(:before_click_confirm_btn) do
            rec.update_attributes!(declined_at: Date.today, decline_reason: "x")
            raise if rec.pendingable? # sanity check
          end

          it "doesn't update anything", :backend do
            expect(rec).to be_declined
            expect(rec.applied_at).to be_nil
          end
        end
      end
    end
  end
end
