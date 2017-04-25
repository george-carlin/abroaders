require 'rails_helper'

RSpec.describe 'admin edit card product page' do
  include_context 'logged in as admin'

  let!(:banks) { Bank.all }
  let(:currencies) { create_list(:currency, 2) }
  before do
    @product = create(
      :card_product,
      currency: currencies[0],
      bp:      :personal,
      network: :visa,
      type:    :credit,
      shown_on_survey: false,
      bank:    banks[0],
    )
    visit edit_admin_card_product_path(@product)
  end

  let(:submit_form) { click_button 'Save Card' }

  example 'form fields' do
    expect(page).to have_field :card_product_name
    expect(page).to have_field :card_product_annual_fee
    expect(page).to have_field :card_product_currency_id
    expect(page).to have_field :card_product_bank_id
    expect(page).to have_field :card_product_shown_on_survey
    expect(page).to have_field :card_product_image
    expect(page).to have_select :card_product_network, selected: 'Visa'
    expect(page).to have_select :card_product_bp, selected: 'Personal'
    expect(page).to have_select :card_product_type, selected: 'Credit'
    expect(page).to have_select :card_product_currency_id, selected: currencies[0].name
  end

  example 'valid update' do
    fill_in :card_product_name, with: 'Chase Visa Something'
    select 'MasterCard', from: :card_product_network
    select 'Business', from: :card_product_bp
    select 'Credit', from: :card_product_type
    fill_in :card_product_annual_fee, with: 549
    select currencies[1].name, from: :card_product_currency_id
    select banks[1].name, from: :card_product_bank_id
    check :card_product_shown_on_survey
    submit_form

    @product.reload
    expect(@product.name).to eq "Chase Visa Something"
    expect(@product.network).to eq "mastercard"
    expect(@product.bp).to eq "business"
    expect(@product.type).to eq "credit"
    expect(@product.annual_fee).to eq 549
    expect(@product.currency).to eq currencies[1]
    expect(@product.bank).to eq banks[1]
    expect(@product).to be_shown_on_survey

    expect(current_path).to eq admin_card_product_path(@product)
  end

  example 'invalid update' do
    fill_in :card_product_name, with: ''

    expect { submit_form }.not_to change { @product.reload.attributes }
  end
end
