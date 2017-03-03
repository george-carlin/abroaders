require 'cells_helper'

RSpec.describe AdminArea::CardProducts::Cell::Identifier do
  def render_cell(product)
    described_class.(product).()
  end

  it "renders the card's unique identifier" do
    product = ::CardProduct.new(
      bank:    Bank.new(personal_code: 1),
      bp:      :personal,
      code:    'ABC',
      network: :visa,
    )
    expect(render_cell(product)).to eq '01-ABC-V'
    # personal card products use odd-numbered bank numbers, business card
    # products use even-numbered ones:
    product.bp = :business
    expect(render_cell(product)).to eq '02-ABC-V'
    product.network = :amex
    expect(render_cell(product)).to eq '02-ABC-A'
    product.network = :mastercard
    expect(render_cell(product)).to eq '02-ABC-M'
    product.network = :unknown_network
    expect(render_cell(product)).to eq '02-ABC-?'
  end
end
