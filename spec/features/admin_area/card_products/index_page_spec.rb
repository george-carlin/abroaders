require 'rails_helper'

RSpec.describe 'admin card product index page' do
  include_context 'logged in as admin'

  subject { page }

  before do
    @product = create(:card_product)
    @hidden_product = create(:card_product, shown_on_survey: false)
    visit admin_card_products_path
  end

  let(:products) { [@product, @hidden_product] }

  it { is_expected.to have_title full_title('Card Products') }

  it 'lists info about each card' do
    expect(page).to have_selector "#card_product_#{@product.id}"
    expect(page).to have_selector "#card_product_#{@hidden_product.id}"

    products.each do |product|
      within "#card_product_#{product.id}" do
        # it has a link to edit each card
        expect(page).to have_link 'Edit', href: edit_admin_card_product_path(product)
        # it displays each card's currency
        expect(page).to have_content product.currency.name
      end
    end

    # says whether or not the card is shown on the survey
    expect(page).to have_selector \
      "#card_product_#{@product.id} .card_shown_on_survey .fa.fa-check"
    expect(page).to have_no_selector \
      "#card_product_#{@hidden_product.id} .card_shown_on_survey .fa.fa-check"
  end
end
