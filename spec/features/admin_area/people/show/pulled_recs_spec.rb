require 'rails_helper'

RSpec.describe 'admin/people#show - pulled recs', :js do
  include_context 'logged in as admin'

  let!(:person) { create(:account, :onboarded, :eligible).owner }
  let!(:offer)  { create_offer }

  example 'pulling a rec' do
    rec = create_card_recommendation(offer: offer, person: person)

    visit admin_person_path(person)

    find("#card_#{rec.id}_pull_btn").click

    expect(page).to have_no_selector "#card_#{rec.id}"
    expect(rec.reload.pulled_at).to be_within(5.seconds).of(Time.zone.now)
  end
end
