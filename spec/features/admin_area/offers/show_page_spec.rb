require 'rails_helper'

RSpec.describe 'admin - show offer page' do
  include_context 'logged in as admin'

  let(:offer)   { create_offer(notes: 'aisjhdoifajsdf') }
  let(:product) { offer.card_product }
  before { visit route }

  let(:route) { admin_offer_path(product, offer) }

  it 'displays information about the offer and product' do
    expect(page).to have_content product.name
    expect(page).to have_content 'CardBenefit'
    expect(page).to have_content offer.notes
  end
end
