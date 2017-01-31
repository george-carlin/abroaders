require 'rails_helper'

module AdminArea
  # this page isn't important at all, but add a quick smoke test in case I
  # break it
  RSpec.describe 'card images page' do
    include_context 'logged in as admin'

    before do
      @products = create_list(:card_product, 2)
      visit images_admin_card_products_path
    end

    it 'lists the cards' do
      @products.each do |product|
        expect(page).to have_content CardProduct::Cell::Identifier.(product).()
      end
    end
  end
end
