require 'rails_helper'

RSpec.describe Offer::Cell::Cost do
  let(:cell) { described_class }

  example '#show' do
    offer    = Struct.new(:cost).new(1234)
    rendered = cell.(offer).()
    expect(rendered).to eq '$1,234.00'
  end
end
