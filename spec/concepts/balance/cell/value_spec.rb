require 'cells_helper'

RSpec.describe Balance::Cell::Value do
  example '#show' do
    balance_class = Struct.new(:value)
    balance = balance_class.new(123456789)
    expect(show(balance).raw).to eq '123,456,789'
  end
end
