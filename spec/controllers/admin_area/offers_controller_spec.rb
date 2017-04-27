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
    let(:offer) { create_offer }
    let(:card_product) { offer.product }

    context 'when no card_product_id is specified' do
      it 'redirects to the nested path' do
        get :edit, params: { id: offer.id }
        expect(response).to redirect_to edit_admin_card_product_offer_path(offer.product, offer)
      end
    end

    context 'when a card_product_id is specified' do
      it 'renders the form' do
        get :edit, params: { id: offer.id, card_product_id: card_product.id }
        expect(response).to have_http_status 200
      end
    end
  end
end
