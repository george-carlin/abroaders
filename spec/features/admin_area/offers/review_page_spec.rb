require 'rails_helper'

RSpec.describe 'admin - review offers page' do
  include_context 'logged in as admin'

  let(:reviewed_date) { Time.zone.yesterday }

  before do
    @live_1 = create(:offer)
    @live_2 = create(:offer, last_reviewed_at: reviewed_date)
    @dead = AdminArea::Offers::Operation::Kill.(id: create(:offer).id)['model']
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
      expect(page).to have_content reviewed_date.to_date.strftime("%m/%d/%Y")
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
