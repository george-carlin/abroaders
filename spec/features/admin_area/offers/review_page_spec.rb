require 'rails_helper'

RSpec.describe 'admin - review offers page' do
  include_context 'logged in as admin'

  before do
    @live_1 = create_offer
    @live_2 = create_offer(:verified)
    @dead   = create_offer(:dead)
    visit review_admin_offers_path
  end

  def offer_selector(offer)
    "#offer_#{offer.id}"
  end

  it 'lists live offers' do
    # (this should be extracted to cells and tested in cell specs)
    [@live_1, @live_2].each do |offer|
      expect(page).to have_selector offer_selector(offer)
    end

    # shows last review date if there is one:
    within offer_selector(@live_1) do
      expect(page).to have_content 'never'
    end
    within offer_selector(@live_2) do
      expect(page).to have_content @live_2.last_reviewed_at.to_date.strftime("%m/%d/%Y")
      expect(page).to have_no_content 'never'
    end

    expect(page).to have_no_selector offer_selector(@dead)
  end

  example 'verifying', :js do
    # it "updates selected last_reviewed_at datetime", js: true do
    now = Time.zone.now
    within offer_selector(@live_1) do
      click_link 'Verify'
      expect(page).to have_content now.strftime("%m/%d/%Y")
    end
  end

  example 'killing an offer', :js do
    selector = offer_selector(@live_1)
    within selector do
      click_link 'Kill'
    end
    expect(page).to have_no_selector selector
  end
end # review page
