require 'rails_helper'

describe Card::Identifier do
  it 'generates an identifier using the bank ID, code, and network' do
    card = Card.new(
      bank:    Bank.new(id: 1),
      bp:      :personal,
      code:    'ABC',
      network: :visa,
    )
    expect(described_class.new(card)).to eq '01-ABC-V'
    # personal cards use odd-numbered bank numbers, business cards use
    # even-numbered ones:
    card.bp = :business
    expect(described_class.new(card)).to eq '02-ABC-V'
    card.network = :amex
    expect(described_class.new(card)).to eq '02-ABC-A'
    card.network = :mastercard
    expect(described_class.new(card)).to eq '02-ABC-M'
    card.network = :unknown_network
    expect(described_class.new(card)).to eq '02-ABC-?'
  end
end
