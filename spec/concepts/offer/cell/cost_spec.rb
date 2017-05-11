require 'cells_helper'

RSpec.describe Offer::Cell::Cost do
  example '#show' do
    offer = Struct.new(:cost).new(1234)
    expect(raw_cell(offer)).to eq '$1,234.00'
  end
end
