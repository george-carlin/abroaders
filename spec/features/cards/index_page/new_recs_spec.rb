require "rails_helper"

RSpec.describe "cards index page - new recommendation", :js do
  include ActionView::Helpers::NumberHelper
  include ApplicationSurveyMacros

  include_context "logged in"

  let(:person) { account.owner }

  let!(:rec) do
    create(
      :card_recommendation,
      person: person,
      recommended_at: recommended_at,
    )
  end

  let(:recommended_at) { Time.zone.today }

  before do
    person.update!(eligible: true)
    visit cards_path
  end

  let(:click_confirm_btn) do
    before_click_confirm_btn
    click_button 'Confirm'
    # FIXME can't figure out a more elegant solution than this:
    sleep 1.5
    rec.reload
  end
  let(:before_click_confirm_btn) { nil }

  example "new recommendation on page", :frontend do
    expect(page).to have_apply_btn(rec)
    expect(page).to have_button decline_btn
    expect(page).to have_button i_applied_btn

    offer = rec.offer
    # TODO this is testing the description. Don't we already have a lower-level test for this?
    expect(page).to have_content(
      "Spend #{number_to_currency(offer.spend)} within #{offer.days} "\
      "days to receive a bonus of "\
      "#{number_with_delimiter(offer.points_awarded)} "\
      "#{rec.product.currency.name} points",
    )

    # 'apply' btn opens the link in a new tab
    btn = find 'a', text: 'Find My Card'
    expect(btn[:target]).to eq '_blank'
  end

  # combining this all into one example because it's so damn slow:
  example 'declining a recommendation' do
    # clicking the button hides the apply/decline btns and shows the form:
    click_button decline_btn
    expect(page).to have_field :card_decline_reason
    expect(page).to have_button 'Confirm'
    expect(page).to have_button 'Cancel'
    expect(page).to have_no_link 'Find My Card'
    expect(page).to have_no_button decline_btn

    # clicking 'cancel' shows the first set of buttons again:
    click_button 'Cancel'
    expect(page).to have_link 'Find My Card'
    expect(page).to have_button decline_btn

    click_button decline_btn

    # fails if you try to submit with no decline reason:
    expect { click_button 'Confirm' }.not_to change { rec.reload.attributes }
    # shows an error message and doesn't save:
    expect(page).to have_content 'Please include a message'
    expect(decline_reason_wrapper[:class]).to match(/\bfield_with_errors\b/)

    # fails if you try to submit a decline reason that's just whitespace:
    fill_in :card_decline_reason, with: '     '
    expect { click_button 'Confirm' }.not_to change { rec.reload.attributes }
    expect(page).to have_content 'Please include a message'
    expect(decline_reason_wrapper[:class]).to match(/\bfield_with_errors\b/)

    # and actually declining successfully

    # this spec fails when run late in the day when your machine's time
    # is earlier than UTC # TZFIXME
    message = 'Just because'
    fill_in :card_decline_reason, with: message
    click_button 'Confirm'
    expect(page).to have_success_message t('cards.index.declined')
    # updates the attributes:
    rec.reload
    expect(rec.decline_reason).to eq message
    expect(rec.declined_at).to eq Time.zone.today # TODO change to datetime
  end

  example "trying to decline a rec that's already declined" do
    click_button decline_btn
    message = "Because I say so, bitch!"
    fill_in :card_decline_reason, with: message

    # This could happen if e.g. they have the same window open in two
    # tabs, and decline the rec in one tab before clicking 'decline'
    # again in the other tab. It should fail gracefully:
    rec.update_attributes!(applied_at: Time.zone.today)
    raise if rec.declinable? # sanity check
    click_confirm_btn

    expect(current_path).to eq cards_path
    expect(page).to have_info_message CardRecommendation::Operation::Decline::COULDNT_DECLINE
  end

  example "clicking the 'I Applied' button" do
    click_button i_applied_btn
    expect(page).to have_no_button i_applied_btn
    expect(page).to have_button approved_btn
    expect(page).to have_button denied_btn
    expect(page).to have_button pending_btn
  end

  describe "clicking the 'I Applied' button" do
    before { click_button i_applied_btn }

    shared_examples "asks to confirm" do
      it "hides the current set of buttons and asks to confirm", :frontend do
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

    describe "clicking 'I was approved'" do
      before { click_button approved_btn }

      include_examples "asks to confirm"

      shared_examples "unapplyable" do
        context "when the account is no longer 'applyable'" do
          # This could happen if e.g. they've made changes in another tab
          let(:before_click_confirm_btn) do
            rec.update_attributes!(declined_at: Time.zone.today, decline_reason: "x")
            raise if rec.openable? # sanity check
          end

          it "doesn't update anything", :backend do
            expect(rec).to be_declined
            expect(rec.opened_at).to be_nil
            expect(rec.applied_at).to be_nil
          end
        end
      end

      context "when I received this rec today" do
        it "shows Confirm/Cancel buttons with no datepicker", :frontend do
          # this spec fails when run late in the day when your machine's time
          # is earlier than UTC # TZFIXME
          expect(page).to have_no_field approved_at
          expect(page).to have_button 'Confirm'
          expect(page).to have_button 'Cancel'
        end

        describe "clicking 'Confirm'" do
          before { click_confirm_btn }

          it "updates the rec's attributes", :backend do
            # this spec fails when run late in the day when your machine's time
            # is earlier than UTC # TZFIXME
            wait_for_ajax
            expect(rec).to be_open
            expect(rec.opened_at).to eq Time.zone.today
            expect(rec.applied_at).to eq Time.zone.today
          end

          include_examples "unapplyable"
        end
      end

      context "when I was recommended this card before today" do
        let(:recommended_at) { Time.zone.yesterday }

        it "shows a date picker and Confirm/Cancel buttons", :frontend do
          expect(page).to have_field approved_at
          expect(page).to have_button 'Cancel'
          expect(page).to have_button 'Confirm'
        end

        describe "picking a date and clicking 'Confirm'" do
          let(:date) { 5.days.ago }
          before do
            set_approved_at_to(date)
            click_confirm_btn
          end

          it "sets the card's attributes", :backend do
            expect(rec).to be_open
            expect(rec.opened_at.to_date).to eq date.to_date
            expect(rec.applied_at.to_date).to eq date.to_date
          end

          include_examples "unapplyable"
        end
      end
    end

    describe "clicking 'I was denied'" do
      before { click_button denied_btn }

      include_examples "asks to confirm"

      context "and clicking 'Confirm'" do
        before { click_confirm_btn }

        specify "card attributes are updated correctly" do
          # this spec fails when run late in the day when your machine's time
          # is earlier than UTC # TZFIXME
          expect(page).to have_content "We strongly recommend"
          expect(rec.status).to eq "denied"
          expect(rec.denied_at).to eq Time.zone.today
          expect(rec.applied_at).to eq Time.zone.today
        end

        context "when the account is no longer 'deniable'" do
          # This could happen if e.g. they've made changes in another tab
          let(:before_click_confirm_btn) do
            rec.update_attributes!(declined_at: Time.zone.today, decline_reason: "x")
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
      before { click_button pending_btn }

      include_examples "asks to confirm"

      context "and clicking 'Confirm'" do
        before { click_confirm_btn }

        it "updates the card's attributes", :backend do
          # this spec fails when run late in the day when your machine's time
          # is earlier than UTC # TZFIXME
          expect(rec.status).to eq "applied"
          expect(rec.applied_at).to eq Time.zone.today
        end

        context "when the account is no longer 'pendingable'" do
          # This could happen if e.g. they've made changes in another tab
          let(:before_click_confirm_btn) do
            rec.update_attributes!(declined_at: Time.zone.today, decline_reason: "x")
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
