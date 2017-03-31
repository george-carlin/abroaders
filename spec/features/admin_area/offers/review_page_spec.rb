require 'rails_helper'

RSpec.describe 'admin - review offers page' do
  include_context 'logged in as admin'

  before do
    @live = create_offer
    @verified = run!(AdminArea::Offers::Operation::Verify, id: create_offer.id)['model']
    @dead = run!(AdminArea::Offers::Operation::Kill, id: create_offer.id)['model']
    visit review_admin_offers_path
  end

  def offer_selector(offer)
    "#offer_#{offer.id}"
  end

  it 'lists live offers' do
    # (this should be extracted to cells and tested in cell specs)
    [@live, @verified].each do |offer|
      expect(page).to have_selector offer_selector(offer)
    end

    # shows last review date if there is one:
    within offer_selector(@live) do
      expect(page).to have_content 'never'
    end
    within offer_selector(@verified) do
      expect(page).to have_content @verified.last_reviewed_at.to_date.strftime("%m/%d/%Y")
      expect(page).to have_no_content 'never'
    end

    expect(page).to have_no_selector offer_selector(@dead)
  end

  example 'verifying', :js do
    # it "updates selected last_reviewed_at datetime", js: true do
    now = Time.zone.now
    within offer_selector(@live) do
      click_link 'Verify'
      expect(page).to have_content now.strftime("%m/%d/%Y")
    end
  end

  example 'killing an offer', :js do
    selector = offer_selector(@live)
    within selector do
      click_link 'Kill'
    end
    expect(page).to have_no_selector selector
  end
end # review page
