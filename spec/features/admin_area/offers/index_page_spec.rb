require 'rails_helper'

RSpec.describe 'admin - offers pages' do
  include_context 'logged in as admin'

  let!(:offer) { verify_offer(create_offer) }

  def offer_selector(offer)
    "#offer_#{offer.id}"
  end

  example 'for all offers' do
    visit admin_offers_path
    expect(page).to have_content offer.card_product.name
    expect(find("tr#offer_#{offer.id}").text).to include(offer.last_reviewed_at.strftime('%m/%d/%Y'))
    expect(find("tr#offer_#{offer.id}").text).to include('CB')
  end

  example 'for offers for a specific card product' do
    visit admin_card_product_offers_path(offer.card_product)
    expect(page).to have_content offer.card_product.name
    expect(find("tr#offer_#{offer.id}").text).to include(offer.last_reviewed_at.strftime('%m/%d/%Y'))
    expect(find("tr#offer_#{offer.id}").text).to include('CB')
  end

  example 'for card product which has no offers' do
    product = create(:card_product)
    visit admin_card_product_offers_path(product)
    expect(page).to have_content 'No offers for this product!'
  end

  example 'verifying' do
    visit admin_offers_path

    now = Time.zone.now
    within offer_selector(offer) do
      click_link 'Verify'
    end
    expect(current_path).to eq admin_offers_path
    expect(page).to have_content now.strftime("%m/%d/%Y")
  end

  example 'killing an offer' do
    visit admin_offers_path

    expect(page).to have_selector "#offer_#{offer.id} .offer_live", text: 'Yes'

    within offer_selector(offer) do
      click_link 'Kill'
    end
    expect(current_path).to eq admin_offers_path
    expect(page).to have_selector "#offer_#{offer.id} .offer_live", text: 'No'
  end
end
