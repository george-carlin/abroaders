require 'rails_helper'

RSpec.describe 'admin card products show page' do
  let(:card_product) { create(:card_product) }
  include_context 'logged in as admin'

  before { visit admin_card_product_path(card_product) }

  # quick smoke test
  example '' do
    expect(page).to have_content card_product.name
  end
end
