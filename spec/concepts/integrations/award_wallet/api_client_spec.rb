require SPEC_ROOT.join('support', 'award_wallet_macros')
require SPEC_ROOT.join('support', 'sample_data_macros')

require 'integrations/award_wallet/api_client'
require 'integrations/award_wallet/error'

# mutation testing fails in two places: 1) when mutant messes with the api_key
# and 2) when mutant messes with the auth headers. But I don't care for now
RSpec.describe Integrations::AwardWallet::APIClient do
  include AwardWalletMacros
  include SampleDataMacros

  pending 'logs all JSON to S3'

  describe '.connected_user' do
    let(:json) { sample_json('award_wallet_user') }
    let(:api_key) { 'abcdefghijk' }

    before do
      @old_api_key = ENV['AWARD_WALLET_API_KEY']
      ENV['AWARD_WALLET_API_KEY'] = api_key

      # stub the HTTP request:
      stub_award_wallet_api(json)
    end
    after { ENV['AWARD_WALLET_API_KEY'] = @old_api_key }

    example '' do
      result = described_class.connected_user(12345)

      expect(result).to eq(
        'user_id' => 12345,
        'full_name' => 'John Smith',
        'status' => 'Free',
        'user_name' => 'JSmith',
        'email' => 'JSmith@email.com',
        'forwarding_email' => 'JSmith@AwardWallet.com',
        'access_level' => 'Regular',
        'connection_type' => 'Connected',
        'accounts_access_level' => 'Full control',
        'accounts_shared_by_default' => true,
        'edit_connection_url' => 'https://business.awardwallet.com/members/connection/112233',
        'account_list_url' => 'https://business.awardwallet.com/account/list#/?agentId=112233',
        'timeline_url' => 'https://business.awardwallet.com/timeline/?agentId=166765#/112233',
        'booking_requests_url' => 'https://business.awardwallet.com/awardBooking/queue?user_filter=332211',
        'accounts' => [
          {
            'account_id' => 7654321,
            'display_name' => 'British Airways (Executive Club)',
            'kind' => 'Airlines',
            'login' => 'johnsmith',
            'autologin_url' => 'https://business.awardwallet.com/account/redirect.php?ID=7654321',
            'update_url' => 'https://business.awardwallet.com/account/edit/7654321?autosubmit=1',
            'edit_url' => 'https://business.awardwallet.com/account/edit/7654321',
            'balance' => '146,780',
            'balance_raw' => 146780,
            'owner' => 'John Smith',
            'error_code' => 1,
            'last_detected_change' => '+750',
            'expiration_date' => '2018-12-10T00:00:00+00:00',
            'last_retrieve_date' => '2016-01-15T00:00:00+00:00',
            'last_change_date' => '2016-01-15T00:49:33+00:00',
            'properties' => [
              { 'name' => 'Next Elite Level', 'value' => 'Bronze', 'kind' => 9 },
              { 'name' => 'Date of joining the club', 'value' => '20 Jun 2013', 'kind' => 5 },
              { 'name' => 'Lifetime Tier Points', 'value' => '35,000' },
              { 'name' => 'Executive Club Tier Points', 'value' => '35,000' },
              { 'name' => 'Card expiry date', 'value' => '31 Mar 2017' },
              { 'name' => 'Membership year ends', 'value' => '08 Feb 2016' },
              { 'name' => 'Last Activity', 'value' => '10-Dec-15', 'kind' => 13 },
              { 'name' => 'Name', 'value' => 'Mr Smith', 'kind' => 12 },
              { 'name' => 'Level', 'value' => 'Blue', 'rank' => 0, 'kind' => 3 },
              { 'name' => 'Membership no', 'value' => '1122334455', 'kind' => 1 },
            ],
            'history' => [
              {
                'fields' => [
                  { 'name' => 'Transaction Date', 'code' => 'PostingDate', 'value' => '3/31/14' },
                  { 'name' => 'Description', 'code' => 'Description', 'value' => 'Expired Points' },
                  { 'name' => 'Type', 'code' => 'Info', 'value' => 'Adjustments' },
                  { 'name' => 'Points', 'code' => 'Miles', 'value' => '-100' },
                ],
              },
              {
                'fields' => [
                  { 'name' => 'Transaction Date', 'code' => 'PostingDate', 'value' => '12/11/13' },
                  { 'name' => 'Description', 'code' => 'Description', 'value' => 'Google Wallet' },
                  { 'name' => 'Type', 'code' => 'Info', 'value' => 'Other Earning' },
                  { 'name' => 'Points', 'code' => 'Miles', 'value' => '+100' },
                ],
              },
              {
                'fields' => [
                  { 'name' => 'Transaction Date', 'code' => 'PostingDate', 'value' => '9/30/12' },
                  { 'name' => 'Description', 'code' => 'Description', 'value' => 'Expired Points' },
                  { 'name' => 'Type', 'code' => 'Info', 'value' => 'Adjustments' },
                  { 'name' => 'Points', 'code' => 'Miles', 'value' => '-1,042' },
                ],
              },
            ],
          }, {
            'account_id' => 654321,
              'display_name' => 'American Airlines (AAdvantage)',
              'kind' => 'Airlines',
              'login' => 'johnsmith',
              'autologin_url' => 'https://business.awardwallet.com/account/redirect.php?ID=654321',
              'update_url' => 'https://business.awardwallet.com/account/edit/654321?autosubmit=1',
              'edit_url' => 'https://business.awardwallet.com/account/edit/654321',
              'balance' => '146,780',
              'balance_raw' => 146780,
              'owner' => 'John Smith',
              'error_code' => 1,
              'last_detected_change' => '+750',
              'expiration_date' => '2018-12-10T00:00:00+00:00',
              'last_retrieve_date' => '2016-01-15T00:00:00+00:00',
              'last_change_date' => '2016-01-15T00:49:33+00:00',
              'properties' => [],
              'history' => [],
          },
        ],
      )
    end

    context 'when API response is an error' do
      let(:json) { '{ "error" : "something\'s wrong, cap\'n!" }' }

      it 'raises an error' do
        expect do
          described_class.connected_user(12345)
        end.to raise_error(
          Integrations::AwardWallet::Error,
          /something's wrong, cap'n!/,
        )
      end
    end

    context 'when AWARD_WALLET_API_KEY is not set in the env' do
      let(:api_key) { nil }

      it 'raises an error' do
        expect do
          described_class.connected_user(12345)
        end.to raise_error Integrations::AwardWallet::Error
      end
    end
  end # .connected_user
end
