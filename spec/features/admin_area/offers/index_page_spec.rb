require 'rails_helper'

RSpec.describe 'admin - offers pages' do
  include_context 'logged in as admin'

  let!(:offer) { verify_offer(create_offer) }

  example 'for all offers' do
    visit admin_offers_path
    expect(page).to have_content offer.product.name
    expect(find("tr#offer_#{offer.id}").text).to include(offer.last_reviewed_at.strftime('%m/%d/%Y'))
    expect(find("tr#offer_#{offer.id}").text).to include('CB')
  end

  example 'for offers for a specific card product' do
    visit admin_card_product_offers_path(offer.product)
    expect(page).to have_content offer.product.name
    expect(find("tr#offer_#{offer.id}").text).to include(offer.last_reviewed_at.strftime('%m/%d/%Y'))
    expect(find("tr#offer_#{offer.id}").text).to include('CB')
  end
end
