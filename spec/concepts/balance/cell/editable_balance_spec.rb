require 'cells_helper'

RSpec.describe Balance::Cell::EditableBalance do
  controller BalancesController

  let(:currency) { Currency.new(id: 1, name: 'Sterling') }
  let(:balance)  { Balance.new(id: 1, value: 1234, currency: currency, updated_at: 5.minutes.ago) }

  it '' do
    rendered = show(balance)
    expect(rendered).to have_content 'Sterling'
    expect(rendered).to have_content '1,234'
  end

  it 'avoids XSS attacks' do
    balance.currency.name = '<hacker>'
    expect(show(balance).to_s).to include('&lt;hacker&gt;')
  end
end
