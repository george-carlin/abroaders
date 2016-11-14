require 'rails_helper'

module AdminArea
  describe OffersController do
    before { sign_in create(:admin) }

    describe 'GET #show' do
      context 'when no card_id is specified' do
        it 'redirects to the nested path' do
          offer = create(:offer)
          get :show, params: { id: offer.id }
          expect(response).to redirect_to admin_card_offer_path(offer.card, offer)
        end
      end
    end

    describe 'GET #edit' do
      context 'when no card_id is specified' do
        it 'redirects to the nested path' do
          offer = create(:offer)
          get :edit, params: { id: offer.id }
          expect(response).to redirect_to edit_admin_card_offer_path(offer.card, offer)
        end
      end
    end
  end
end
