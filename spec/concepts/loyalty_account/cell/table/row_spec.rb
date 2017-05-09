require 'cells_helper'

RSpec.describe LoyaltyAccount::Cell::Table::Row do
  controller BalancesController

  let(:currency) { Currency.new(id: 1, name: 'Sterling') }
  let(:person) { Person.new(id: 1, first_name: 'George') }
  let(:balance) { Balance.new(id: 1, person: person, value: 1234, currency: currency, updated_at: 5.minutes.ago) }
  let(:la) { LoyaltyAccount.build(balance) }

  it 'for an Abroaders balance' do
    rendered = show(la)
    expect(rendered).to have_content 'Sterling'
    expect(rendered).to have_content '1,234'
    expect(rendered).to have_link 'Edit'
    expect(rendered).to have_link 'Delete'
    # when :simple is false (which is the default):
    expect(rendered).to have_selector 'td', count: 7
    # show person name in the 'owner' column
    expect(rendered).to have_content 'George'
    # expiration date:
    expect(rendered).to have_content 'Unknown'
  end

  it 'avoids XSS attacks' do
    balance.currency.name = '<hacker>'
    expect(show(la).to_s).to include('&lt;hacker&gt;')
  end

  it 'for an AwardWallet account' do
    owner = AwardWalletOwner.new(person: person, name: 'Puta Madre')
    awa = AwardWalletAccount.new(
      id: 1,
      aw_id: 234,
      award_wallet_owner: owner,
      balance_raw: 4321,
      display_name: 'My currency',
      login: 'GeorgeMillo',
      updated_at: 5.minutes.ago,
    )
    account = LoyaltyAccount.build(awa)

    rendered = show(account)
    expect(rendered).to have_content 'My currency'
    expect(rendered).to have_content '4,321'
    expect(rendered).to have_content 'GeorgeMillo'
    expect(rendered).to have_content 'Puta Madre'
    expect(rendered).to have_content 'Unknown' # expiration date
    expect(rendered).to have_link 'Edit'
  end

  example 'with :simple option' do
    rendered = show(la, simple: true)
    expect(rendered).to have_selector 'td', count: 4
    # these columns are shown regardless of the :simple option:
    expect(rendered).to have_content 'Sterling'
    expect(rendered).to have_content '1,234'
    expect(rendered).to have_link 'Edit'
    expect(rendered).to have_link 'Delete'
    # no 'owner', 'account', or 'expiration' columns
    expect(rendered).not_to have_content 'George'
    expect(rendered).not_to have_content 'Unknown'
  end
end
