require 'rails_helper'

RSpec.describe CardProduct::Identifier do
  it "generates the card's unique identifier" do
    product = CardProduct.new(
      bank:    Bank.new(personal_code: 1),
      bp:      :personal,
      code:    'ABC',
      network: :visa,
    )
    expect(described_class.new(product)).to eq '01-ABC-V'
    # personal card products use odd-numbered bank numbers, business card
    # products use even-numbered ones:
    product.bp = :business
    expect(described_class.new(product)).to eq '02-ABC-V'
    product.network = :amex
    expect(described_class.new(product)).to eq '02-ABC-A'
    product.network = :mastercard
    expect(described_class.new(product)).to eq '02-ABC-M'
    product.network = :unknown_network
    expect(described_class.new(product)).to eq '02-ABC-?'
  end
end
