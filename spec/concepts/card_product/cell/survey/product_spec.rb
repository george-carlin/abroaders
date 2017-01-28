require 'rails_helper'

RSpec.describe CardProduct::Cell::Survey::Product, type: :view do
  let(:product) { create(:product, name: 'Sapphire', network: :visa) }
  let(:cell)    { described_class.(product, context: CELL_CONTEXT).show }

  describe 'card name' do
    context 'for a business card' do
      before { product.update!(bp: :business) }

      it 'has the format "<product name>, business, <network>"' do
        expect(cell).to have_content 'Sapphire business Visa'
      end
    end

    context 'for a personal card' do
      before { product.update!(bp: :personal) }

      it 'has the format "<card name>, <network>"' do
        expect(cell).to have_content 'Sapphire Visa'
      end
    end
  end
end
