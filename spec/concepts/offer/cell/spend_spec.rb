require 'rails_helper'

RSpec.describe Offer::Cell::Spend do
  let(:cell) { described_class }

  example '#show' do
    offer    = Struct.new(:spend).new(4321)
    rendered = cell.(offer).()
    expect(rendered).to eq '$4,321.00'
  end
end
