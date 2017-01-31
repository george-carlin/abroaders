require 'rails_helper'

RSpec.describe CardProduct::Cell::FullName do
  let(:bank)    { Bank.new(name: 'Chase') }
  let(:product) { CardProduct.new(name: 'Sapphire', bank: bank, network: :visa, bp: :personal) }

  def cell(product, opts = {})
    described_class.(product, opts).()
  end

  example 'regular' do
    expect(cell(product)).to eq 'Sapphire Visa'
  end

  example 'with_bank' do
    expect(cell(product, with_bank: true)).to eq 'Chase Sapphire Visa'
  end

  example 'when bank is American Express' do
    bank.name = 'American Express'
    product.network = :amex
    expect(cell(product)).to eq 'Sapphire American Express'
    # don't be redundant
    expect(cell(product, with_bank: true)).to eq 'American Express Sapphire'
  end

  example 'when network is unknown' do
    product.network = :unknown_network
    expect(cell(product)).to eq 'Sapphire'
  end

  example 'business card' do
    product.bp = :business
    expect(cell(product)).to eq 'Sapphire business Visa'
  end

  example 'network_in_brackets' do
    expect(cell(product, network_in_brackets: true)).to eq 'Sapphire (Visa)'
    product.network = :amex
    expect(cell(product, network_in_brackets: true)).to eq 'Sapphire (American Express)'
    product.bank.name = 'American Express'
    expect(cell(product, network_in_brackets: true)).to eq 'Sapphire (American Express)'
    # has no effect when the network isn't shown:
    expect(cell(product, network_in_brackets: true, with_bank: true)).to eq 'American Express Sapphire'
    product.network = :unknown_network
    expect(cell(product, network_in_brackets: true)).to eq 'Sapphire'
  end
end
