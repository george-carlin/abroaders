require 'cells_helper'

RSpec.describe CardProduct::Cell::Survey::Product do
  let(:bank) { Bank.all.first }
  let(:product) do
    CardProduct.new(name: 'Sapphire', network: 'visa', bank: bank, annual_fee_cents: 125_00)
  end
  let(:rendered) { show(product) }

  describe 'card name' do
    example 'for a business card' do
      product.bp = 'business'
      # it 'has the format "<product name>, business, <network>"' do
      expect(rendered).to have_content 'Sapphire business Visa'
    end

    example 'for a personal card' do
      product.bp = 'personal'
      # it 'has the format "<card name>, <network>"' do
      expect(rendered).to have_content 'Sapphire Visa'
    end
  end
end
