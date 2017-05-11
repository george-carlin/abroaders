require 'cells_helper'

RSpec.describe Currency::Cell::ShortName do
  example '' do
    currency = Struct.new(:name).new('Bank of America (Americard Points)')
    expect(raw_cell(currency)).to eq 'Bank of America'
  end
end
