require 'cells_helper'

RSpec.describe Balance::Cell::Value do
  example '#show' do
    balance = Struct.new(:value).new(123456789)
    expect(raw_cell(balance)).to eq '123,456,789'
  end
end
