require 'rails_helper'

RSpec.describe "cards index page - new recommendation", :js do
  include ActionView::Helpers::NumberHelper
  include ApplicationSurveyMacros
  include ZapierWebhooksMacros

  let(:account) { create_account(:onboarded, :eligible) }
  let(:person) { account.owner }

  let(:recommended_at) { Time.zone.today }

  let!(:rec) do
    create_rec(person_id: person.id).tap { |r| r.update!(recommended_at: recommended_at) }
  end

  before do
    login_as_account(account)
    visit cards_path
  end

  let(:click_confirm_btn) do
    click_button 'Confirm'
    sleep 1.5 # can't figure out a more elegant solution than this
    rec.reload
  end

  let(:offer_description) { Offer::Cell::Description.(rec.offer) }

  example 'new recommendation on page' do
    expect(page).to have_find_card_btn(rec)
    expect(page).to have_button decline_btn
    expect(page).to have_button i_applied_btn
    expect(page).to have_content offer_description
    # 'apply' btn (which is actually a link) opens the url in a new tab:
    expect(find('a', text: 'Find My Card')[:target]).to eq '_blank'
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

    expect_not_to_queue_card_opened_webhook

    # and actually declining successfully:
    message = 'Just because'
    fill_in :card_decline_reason, with: message
    click_button 'Confirm'
    expect(page).to have_success_message t('cards.index.declined')
    # updates the attributes:
    rec.reload
    expect(rec.decline_reason).to eq message
    expect(rec.declined_at).to be_within(5.seconds).of(Time.zone.now)

    # the rec disappears from the page:
    expect(page).to have_no_content offer_description
  end

  example "trying to decline a rec that's already declined" do
    expect_not_to_queue_card_opened_webhook
    # This could happen if e.g. they have the page open in two tabs:
    click_button decline_btn
    fill_in :card_decline_reason, with: 'Because I say so!'
    rec.update_attributes!(applied_on: Time.zone.now)
    click_confirm_btn
    expect(current_path).to eq cards_path
    expect(page).to have_info_message CardRecommendation::Decline::COULDNT_DECLINE
  end

  describe 'clicking "I Applied"' do
    before { click_button i_applied_btn }

    example '' do
      expect(page).to have_no_button i_applied_btn
      expect(page).to have_button approved_btn
      expect(page).to have_button denied_btn
      expect(page).to have_button pending_btn
    end

    describe 'clicking "I was approved"' do
      before { click_button approved_btn }

      it_asks_to_confirm(has_pending_btn: true)

      context 'if I received this rec today' do
        across_time_zones do
          it 'shows Confirm/Cancel buttons with no datepicker' do
            expect(page).to have_no_field approved_at
            expect(page).to have_button 'Confirm'
            expect(page).to have_button 'Cancel'
          end
        end

        example 'clicking "Confirm"' do
          expect_to_queue_card_opened_webhook_with_id(rec.id)
          click_confirm_btn
          # fails when run late in the day in pre-UTC TZs TZFIXME:
          wait_for_ajax
          expect(rec).to be_opened
          expect(rec.opened_on).to eq Time.zone.today
          expect(rec.applied_on).to eq Time.zone.today

          expect(page).to have_no_link 'Find My Card'
          expect(page).to have_no_button decline_btn
        end
      end

      context 'if I was recommended this card before today' do
        let(:recommended_at) { Time.zone.yesterday }

        it 'shows a date picker and Confirm/Cancel buttons' do
          expect(page).to have_field approved_at
          expect(page).to have_button 'Cancel'
          expect(page).to have_button 'Confirm'
        end

        example 'picking a date and clicking "Confirm"' do
          expect_to_queue_card_opened_webhook_with_id(rec.id)
          date = 5.days.ago
          set_approved_at_to(date)
          click_confirm_btn

          expect(rec).to be_opened
          expect(rec.opened_on.to_date).to eq date.to_date
          expect(rec.applied_on.to_date).to eq date.to_date

          expect(page).to have_no_link 'Find My Card'
          expect(page).to have_no_button decline_btn
        end
      end
    end

    describe 'clicking "I was denied"' do
      before { click_button denied_btn }

      it_asks_to_confirm(has_pending_btn: true)

      example 'and clicking "Confirm"' do
        expect_not_to_queue_card_opened_webhook
        click_confirm_btn
        # fails when run late in the day in pre-UTC TZs TZFIXME:
        expect(page).to have_content 'We strongly recommend'
        expect(rec.status).to eq 'denied'
        expect(rec.denied_at).to be_within(5.seconds).of(Time.zone.now)
        expect(rec.applied_on).to eq Time.zone.today

        expect(page).to have_no_link 'Find My Card'
        expect(page).to have_no_button decline_btn
        expect(page).to have_button i_called_btn(rec)
      end
    end

    describe 'clicking "I\'m still waiting to hear back"' do
      before { click_button pending_btn }

      it_asks_to_confirm(has_pending_btn: true)

      example 'and clicking "Confirm"' do
        expect_not_to_queue_card_opened_webhook
        click_confirm_btn
        # fails when run late in the day in pre-UTC TZs TZFIXME:
        expect(rec.status).to eq 'applied'
        expect(rec.applied_on).to eq Time.zone.today

        expect(page).to have_no_link 'Find My Card'
        expect(page).to have_no_button decline_btn
        expect(page).to have_button i_called_btn(rec)
      end
    end
  end

  describe 'when the user does something weird' do
    # Handle the case(s) where the user submits the same action twice, e.g.
    # if they have the cards page open in multiple tabs and click the
    # same buttons on each one.

    example 'opening when not possible' do
      expect_not_to_queue_card_opened_webhook
      click_button i_applied_btn
      click_button approved_btn
      rec.update_attributes!(declined_at: Time.zone.now, decline_reason: "x")
      click_confirm_btn
      rec.reload

      expect(rec).to be_declined
      expect(rec.opened_on).to be_nil
      expect(rec.applied_on).to be_nil
    end

    example 'denied when not possible' do
      expect_not_to_queue_card_opened_webhook
      click_button i_applied_btn
      click_button denied_btn
      rec.update_attributes!(declined_at: Time.zone.now, decline_reason: "x")
      click_confirm_btn
      rec.reload

      expect(rec).to be_declined
      expect(rec.denied_at).to be_nil
      expect(rec.applied_on).to be_nil
    end

    example 'denied when not possible' do
      expect_not_to_queue_card_opened_webhook
      click_button i_applied_btn
      click_button pending_btn
      rec.update_attributes!(declined_at: Time.zone.now, decline_reason: "x")
      click_confirm_btn
      rec.reload

      expect(rec).to be_declined
      expect(rec.applied_on).to be_nil
    end
  end
end
