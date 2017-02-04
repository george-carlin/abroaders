require 'rails_helper'

RSpec.describe Balance::Cell::Value do
  let(:cell) { described_class }

  example '#show' do
    balance_class = Struct.new(:value)
    balance = balance_class.new(123456789)
    expect(cell.(balance).()).to eq '123,456,789'
  end
end
