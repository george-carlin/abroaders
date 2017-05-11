require 'cells_helper'

RSpec.describe Offer::Cell::PointsAwarded do
  example '#show' do
    offer = Struct.new(:points_awarded).new(1_234_567)
    expect(raw_cell(offer)).to eq '1,234,567'
  end
end
