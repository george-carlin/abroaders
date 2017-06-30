require 'rails_helper'

RSpec.describe 'admin - edit card rec page', :js do
  include_context 'logged in as admin'

  let(:rec) { create_card_recommendation }

  let(:submit_form) { click_button 'Save' }

  example 'updating decline reason' do
    visit edit_admin_card_recommendation_path(rec)

    expect(page).to have_field :card_decline_reason
    expect(page).to have_select :card_declined_at_1i, disabled: true
    expect(page).to have_select :card_declined_at_2i, disabled: true
    expect(page).to have_select :card_declined_at_3i, disabled: true

    check :toggle_declined_at
    expect(page).to have_select :card_declined_at_1i, disabled: false
    expect(page).to have_select :card_declined_at_2i, disabled: false
    expect(page).to have_select :card_declined_at_3i, disabled: false

    raise unless rec.declined_at.nil? && rec.decline_reason.nil? # sanity check

    fill_in :card_decline_reason, with: 'because'

    submit_form
    rec.reload

    expect(rec.declined_at).not_to be_nil
    expect(rec.decline_reason).to eq 'because'
  end

  example 'updating dates' do
    visit edit_admin_card_recommendation_path(rec)

    # Not gonna test them all super-thoroughly, this is just a smoke test
    check :toggle_applied_on
    check :toggle_denied_at
    check :toggle_called_at
    check :toggle_redenied_at

    # simply checking the checkbox should mean that dates get created (based
    # on the default value of the <select>).

    submit_form
    rec.reload

    # unchanged:
    expect(rec.decline_reason).to be_nil
    expect(rec.declined_at).to be_nil
    expect(rec.nudged_at).to be_nil

    expect(rec.applied_on).not_to be_nil
    expect(rec.denied_at).not_to be_nil
    expect(rec.called_at).not_to be_nil
    expect(rec.recommended_at).not_to be_nil
    expect(rec.redenied_at).not_to be_nil
  end

  example 'setting non-nil dates to nil' do
    rec.update!(
      applied_on: Time.now,
      denied_at: Time.now,
      nudged_at: Time.now,
      called_at: Time.now,
      redenied_at: Time.now,
    )
    visit edit_admin_card_recommendation_path(rec)

    uncheck :toggle_applied_on
    uncheck :toggle_denied_at
    uncheck :toggle_nudged_at
    uncheck :toggle_called_at
    uncheck :toggle_redenied_at

    # simply checking the checkbox should mean that dates get created (based
    # on the default value of the <select>).

    submit_form
    rec.reload

    # unchanged:
    expect(rec.applied_on).to be_nil
    expect(rec.denied_at).to be_nil
    expect(rec.nudged_at).to be_nil
    expect(rec.called_at).to be_nil
    expect(rec.redenied_at).to be_nil
  end
end
