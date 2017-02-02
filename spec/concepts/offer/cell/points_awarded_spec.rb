require 'rails_helper'

RSpec.describe Offer::Cell::PointsAwarded do
  let(:cell) { described_class }

  example '#show' do
    offer    = Struct.new(:points_awarded).new(1_234_567)
    rendered = cell.(offer).()
    expect(rendered).to eq '1,234,567'
  end
end
