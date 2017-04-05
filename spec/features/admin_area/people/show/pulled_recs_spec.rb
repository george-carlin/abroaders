require 'rails_helper'

RSpec.describe 'admin/people#show - pulled recs', :js do
  include_context 'logged in as admin'

  let!(:person) { create(:account, :onboarded, :eligible).owner }
  let!(:offer)  { create_offer }

  example 'displaying link to pulled recs' do
    pulled   = create_card_recommendation(:pulled, offer: offer, person: person)
    unpulled = create_card_recommendation(offer: offer, person: person)

    visit admin_person_path(person)

    expect(page).to have_no_selector "#card_#{pulled.id}"
    expect(page).to have_selector "#card_#{unpulled.id}"
    expect(page).to have_link 'View 1 pulled recommendation'
  end

  example 'pulling a rec' do
    rec = create_card_recommendation(offer: offer, person: person)

    visit admin_person_path(person)

    find("#card_#{rec.id}_pull_btn").click

    expect(page).to have_no_selector "#card_#{rec.id}"
    expect(rec.reload.pulled_at).to be_within(5.seconds).of(Time.zone.now)
  end
end
