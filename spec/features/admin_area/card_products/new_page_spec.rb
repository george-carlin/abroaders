require 'rails_helper'

RSpec.describe 'admin new card product page' do
  include_context 'logged in as admin'

  subject { page }

  let(:image_path) { Rails.root.join('spec', 'support', 'example_card_image.png') }

  # TODO - annual fee needs upper and lower value limits. make sure we're
  # trimming whitespace too

  let!(:banks) { create_list(:bank, 2) }
  let!(:currencies) { create_list(:currency, 2) }
  before { visit new_admin_card_product_path }

  let(:submit_form) { click_button 'Save Card' }

  # for some reason the have_select matchers here don't work properly unless
  # JS is activated :/
  example 'form fields', :js do
    expect(page).to have_field :card_product_name
    expect(page).to have_field :card_product_annual_fee
    expect(page).to have_field :card_product_currency_id
    expect(page).to have_field :card_product_bank_id
    expect(page).to have_field :card_product_shown_on_survey
    expect(page).to have_field :card_product_image
    expect(page).to have_select :card_product_bp, selected: 'Business'
    expect(page).to have_select :card_product_network, selected: 'Unknown'
    expect(page).to have_select :card_product_type, selected: 'Unknown'
    expect(page).to have_select :card_product_currency_id, selected: 'No currency'
  end

  example 'valid save' do
    currency = currencies[0]

    fill_in :card_product_name, with: 'Chase Visa Something'
    select 'MasterCard', from: :card_product_network
    select 'Business',   from: :card_product_bp
    select 'Credit',     from: :card_product_type
    fill_in :card_product_annual_fee, with: 549 # .99
    select currency.name, from: :card_product_currency_id
    select banks[1].name, from: :card_product_bank_id
    uncheck :card_product_shown_on_survey
    attach_file :card_product_image, image_path

    expect { submit_form }.to change { CardProduct.count }.by(1)

    # shows the new product:
    product = CardProduct.last
    expect(page).to have_selector 'h1', text: 'Chase Visa Something'
    expect(page).to have_content 'MasterCard'
    expect(page).to have_content 'business'
    expect(page).to have_content 'Credit'
    expect(page).to have_content '$549.00' # 99"
    expect(page).to have_content currency.name
    expect(page).to have_content banks[1].name
    expect(page).to have_selector "img[src='#{product.image.url}']"
  end

  example 'valid save - stripping trailing whitespace' do
    fill_in :card_product_name, with: '    something  '
    fill_in :card_product_annual_fee, with: 549 # .99
    attach_file :card_product_image, image_path
    submit_form

    expect(CardProduct.last.name).to eq 'something'
  end

  example 'valid save - product with no currency' do
    fill_in :card_product_name, with: 'Something'
    fill_in :card_product_annual_fee, with: 549
    attach_file :card_product_image, image_path

    expect { submit_form }.to change { CardProduct.count }.by(1)
    expect(CardProduct.last.currency).to be_nil
  end

  example 'valid save - decimal values for annual fee' do
    fill_in :card_product_name, with: 'Something'
    fill_in :card_product_annual_fee, with: 549.99
    attach_file :card_product_image, image_path

    expect { submit_form }.to change { CardProduct.count }.by(1)
    expect(CardProduct.last.annual_fee_cents).to eq 549_99
  end

  example 'invalid save' do
    expect { submit_form }.not_to change { CardProduct.count }
  end
end
