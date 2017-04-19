require 'rails_helper'

RSpec.describe AdminArea::OffersController do
  before { sign_in create_admin }

  describe 'GET #show' do
    context 'when no product_id is specified' do
      it 'redirects to the nested path' do
        offer = create_offer
        get :show, params: { id: offer.id }
        expect(response).to redirect_to admin_card_product_offer_path(offer.product, offer)
      end
    end
  end

  describe 'GET #edit' do
    context 'when no card_id is specified' do
      it 'redirects to the nested path' do
        offer = create_offer
        get :edit, params: { id: offer.id }
        expect(response).to redirect_to edit_admin_card_product_offer_path(offer.product, offer)
      end
    end
  end
end
