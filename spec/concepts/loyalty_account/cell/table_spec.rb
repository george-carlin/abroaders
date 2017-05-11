require 'cells_helper'

RSpec.describe LoyaltyAccount::Cell::Table do
  let(:balance) { create(:balance) }

  context 'headers' do
    def headers(rendered)
      rendered.native.xpath('//th').map(&:text)
    end

    example 'with :simple option' do
      rendered = cell([], simple: true).()
      expect(headers(rendered)).to eq [
        'Award Program',
        'Balance',
        'Last Updated',
        '',
      ]
    end

    example 'without :simple option' do
      rendered = cell([]).()
      expect(headers(rendered)).to eq [
        'Award Program',
        'Owner',
        'Account',
        'Balance',
        'Expires',
        'Last Updated',
        '',
      ]
    end
  end
end
