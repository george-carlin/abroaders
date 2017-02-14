require 'cells_helper'

RSpec.describe Currency::Cell::ShortName do
  example '' do
    currency = Struct.new(:name).new('Bank of America (Americard Points)')
    expect(show(currency).raw).to eq 'Bank of America'
  end
end
