require 'cells_helper'

RSpec.describe Offer::Cell::Spend do
  example '#show' do
    offer = Struct.new(:spend).new(4321)
    expect(show(offer).raw).to eq '$4,321.00'
  end
end
