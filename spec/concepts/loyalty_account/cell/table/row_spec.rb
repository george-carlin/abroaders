require 'cells_helper'

RSpec.describe LoyaltyAccount::Cell::Table::Row do
  controller BalancesController

  let(:current_account) { Account.new }

  let(:time_0) { Time.new(2016, 2, 3, 13, 3, 32) }
  let(:time_1) { Time.new(2017, 1, 5, 23, 12, 19) }
  let(:time_2) { Time.new(2022, 1, 5, 23, 12, 19) }

  let(:currency) { Currency.new(id: 1, name: 'Sterling') }
  let(:person) { current_account.build_owner(id: 1, first_name: 'George') }
  let(:balance) { Balance.new(id: 1, person: person, value: 1234, currency: currency, updated_at: time_0) }
  let(:la) { LoyaltyAccount.build(balance) }

  it 'for an Abroaders balance' do
    # when current account is not connected to AwardWallet:
    rendered = cell(la).()

    expect(rendered).to have_content 'Sterling'
    expect(rendered).to have_content '1,234'
    expect(rendered).to have_link 'Edit'
    expect(rendered).not_to have_button 'Edit'
    expect(rendered).to have_link 'Delete'
    expect(rendered).to have_selector 'td', count: 4
    # no 'owner' or 'expiration date' cols:
    expect(rendered).not_to have_content 'George'
    expect(rendered).not_to have_content 'Unknown'
    expect(rendered).to have_content time_0.strftime('%D')
    expect(rendered).not_to have_content time_1.strftime('%D')
  end

  it 'avoids XSS attacks' do
    balance.currency.name = '<hacker>'
    expect(raw_cell(la)).to include('&lt;hacker&gt;')
  end

  context 'when current account is connected to AwardWallet' do
    before do
      allow(current_account).to receive(:award_wallet?) { true }
    end

    it 'shows all columns for Abroaders balances' do
      rendered = cell(la).()

      expect(rendered).to have_selector 'td', count: 7
      # these columns are shown for all accounts
      expect(rendered).to have_content 'Sterling'
      expect(rendered).to have_content '1,234'
      expect(rendered).to have_link 'Edit'
      expect(rendered).not_to have_button 'Edit'
      expect(rendered).to have_link 'Delete'
      # 'owner' = person name, 'expires' = Unknown
      expect(rendered).to have_content 'George'
      expect(rendered).to have_content 'Unknown'
    end

    describe 'AwardWallet account' do
      let(:owner) { AwardWalletOwner.new(person: person, name: 'Puta Madre') }
      let(:awa) do
        AwardWalletAccount.new(
          id: 1,
          aw_id: 234,
          award_wallet_owner: owner,
          balance_raw: 4321,
          display_name: 'My currency',
          last_retrieve_date: time_1,
          expiration_date: time_2,
          login: 'GeorgeMillo',
          updated_at: 10.minutes.ago,
        )
      end
      let(:la) { LoyaltyAccount.build(awa) }

      example '' do
        rendered = cell(la).()
        expect(rendered).to have_content 'My currency'
        expect(rendered).to have_content '4,321'
        expect(rendered).to have_content 'GeorgeMillo'
        expect(rendered).to have_content 'Puta Madre'
        expect(rendered).not_to have_link 'Edit', exact: true
        expect(rendered).to have_button 'Edit'
        # displays last_retrieve_date timestamp, not updated_at timestamp
        expect(rendered).not_to have_content awa.updated_at.strftime('%D')
        expect(rendered).to have_content time_1.strftime('%D')

        expiration_date = cell(LoyaltyAccount::Cell::ExpirationDate, la).to_s.text

        expect(rendered).to have_content expiration_date
      end

      example 'with unknown last_retrieve_date' do
        awa.last_retrieve_date = nil
        rendered = cell(la).()
        expect(rendered).to have_content 'Unknown'
      end
    end
  end
end
