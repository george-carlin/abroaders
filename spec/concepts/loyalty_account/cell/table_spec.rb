require 'cells_helper'

RSpec.describe LoyaltyAccount::Cell::Table do
  include AwardWalletMacros

  let(:balance) { create(:balance) }

  context 'headers' do
    def headers(rendered)
      rendered.native.xpath('//th').map(&:text)
    end

    let(:current_account) { create_account(:onboarded) }

    example 'when current account is not connected to AW' do
      rendered = cell([], account: current_account).()

      expect(headers(rendered)).to eq [
        'Award Program',
        'Balance',
        'Last Updated',
        '',
      ]
    end

    example 'when current account is connected to AW' do
      setup_award_wallet_user_from_sample_data(current_account)
      rendered = cell([], account: current_account).()

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
