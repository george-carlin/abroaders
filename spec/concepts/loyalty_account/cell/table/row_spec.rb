require 'cells_helper'

RSpec.describe LoyaltyAccount::Cell::Table::Row do
  controller BalancesController

  let(:currency) { Currency.new(id: 1, name: 'Sterling') }
  let(:person) { Person.new(id: 1, first_name: 'George') }
  let(:balance) { Balance.new(id: 1, person: person, value: 1234, currency: currency, updated_at: 5.minutes.ago) }
  let(:la) { LoyaltyAccount.build(balance) }

  it '' do
    rendered = show(la)
    expect(rendered).to have_content 'Sterling'
    expect(rendered).to have_content '1,234'
  end

  it 'avoids XSS attacks' do
    balance.currency.name = '<hacker>'
    expect(show(la).to_s).to include('&lt;hacker&gt;')
  end
end
