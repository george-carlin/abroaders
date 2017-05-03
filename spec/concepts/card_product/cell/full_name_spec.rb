require 'cells_helper'

RSpec.describe CardProduct::Cell::FullName do
  let(:chase) { Bank.find_by_name!('Chase') }
  let(:amex) { Bank.find_by_name!('American Express') }
  let(:product) { CardProduct.new(name: 'Sapphire', bank: chase, network: :visa, personal: true) }

  example 'regular' do
    expect(show(product).raw).to eq 'Sapphire Visa'
  end

  example 'with_bank' do
    expect(show(product, with_bank: true).raw).to eq 'Chase Sapphire Visa'
  end

  example 'when bank is American Express' do
    product.network = :amex
    product.bank = amex
    expect(show(product).raw).to eq 'Sapphire American Express'
    # don't be redundant
    expect(show(product, with_bank: true).raw).to eq 'American Express Sapphire'
  end

  example 'when network is unknown' do
    product.network = :unknown_network
    expect(show(product).raw).to eq 'Sapphire'
  end

  example 'business card' do
    product.personal = false
    expect(show(product).raw).to eq 'Sapphire business Visa'
  end

  example 'network_in_brackets' do
    expect(show(product, network_in_brackets: true).raw).to eq 'Sapphire (Visa)'
    product.network = :amex
    expect(show(product, network_in_brackets: true).raw).to eq 'Sapphire (American Express)'
    product.bank = amex
    expect(show(product, network_in_brackets: true).raw).to eq 'Sapphire (American Express)'
    # has no effect when the network isn't shown:
    expect(show(product, network_in_brackets: true, with_bank: true).raw).to eq 'American Express Sapphire'
    product.network = :unknown_network
    expect(show(product, network_in_brackets: true).raw).to eq 'Sapphire'
  end
end
