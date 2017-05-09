require 'cells_helper'

RSpec.describe CardProduct::Cell::Network do
  it 'covers all networks' do
    CardProduct::Network.values.each do |network|
      expect do
        described_class.(CardProduct.new(network: network)).()
      end.not_to raise_error
    end
  end
end
