require 'rails_helper'

RSpec.describe ::Currency::Cell do
  let(:currency) { Currency.new(name: 'Bank of America (Americard Points)') }
  let(:cell)     { ::Currency::Cell.(currency) }

  example '#short_name' do
    expect(cell.short_name).to eq 'Bank of America'
  end
end
