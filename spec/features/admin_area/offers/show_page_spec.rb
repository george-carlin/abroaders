require 'rails_helper'

RSpec.describe 'admin - offers pages' do
  include_context 'logged in as admin'

  let(:offer)   { create_offer(notes: 'aisjhdoifajsdf') }
  let(:product) { offer.product }
  before { visit route }

  let(:route) { admin_card_product_offer_path(product, offer) }

  describe 'when accessing the shallow path' do
    let(:route) { admin_offer_path(offer) }
    it 'redirects to the nested path' do
      expect(current_path).to eq admin_card_product_offer_path(product, offer)
    end
  end

  it 'displays information about the offer and product' do
    expect(page).to have_content product.name
    expect(page).to have_content 'CardBenefit'
    expect(page).to have_content offer.notes
  end
end
