require 'cells_helper'

RSpec.describe LoyaltyAccount::Cell::Table::Row do
  controller BalancesController

  let(:current_account) { Account.new }

  let(:currency) { Currency.new(id: 1, name: 'Sterling') }
  let(:person) { current_account.build_owner(id: 1, first_name: 'George') }
  let(:balance) { Balance.new(id: 1, person: person, value: 1234, currency: currency, updated_at: 5.minutes.ago) }
  let(:la) { LoyaltyAccount.build(balance) }

  it 'for an Abroaders balance' do
    # when current account is not connected to AwardWallet:
    rendered = cell(la).()

    expect(rendered).to have_content 'Sterling'
    expect(rendered).to have_content '1,234'
    expect(rendered).to have_link 'Edit'
    expect(rendered).to have_link 'Delete'
    expect(rendered).to have_selector 'td', count: 4
    # no 'owner' or 'expiration date' cols:
    expect(rendered).not_to have_content 'George'
    expect(rendered).not_to have_content 'Unknown'
  end

  it 'avoids XSS attacks' do
    balance.currency.name = '<hacker>'
    expect(raw_cell(la)).to include('&lt;hacker&gt;')
  end

  context 'when current account is connected to AwardWallet' do
    before do
      allow(current_account).to receive(:connected_to_award_wallet?) { true }
    end

    it 'shows all columns for Abroaders balances' do
      rendered = cell(la).()

      expect(rendered).to have_selector 'td', count: 7
      # these columns are shown for all accounts
      expect(rendered).to have_content 'Sterling'
      expect(rendered).to have_content '1,234'
      expect(rendered).to have_link 'Edit'
      expect(rendered).to have_link 'Delete'
      # 'owner' = person name, 'expires' = Unknown
      expect(rendered).to have_content 'George'
      expect(rendered).to have_content 'Unknown'
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
      la = LoyaltyAccount.build(awa)

      rendered = cell(la).()
      expect(rendered).to have_content 'My currency'
      expect(rendered).to have_content '4,321'
      expect(rendered).to have_content 'GeorgeMillo'
      expect(rendered).to have_content 'Puta Madre'
      expect(rendered).to have_content 'Unknown' # expiration date
      expect(rendered).to have_link 'Edit'
    end
  end
end
