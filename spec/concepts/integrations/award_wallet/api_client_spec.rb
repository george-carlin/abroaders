require SPEC_ROOT.join('support', 'award_wallet_macros')
require SPEC_ROOT.join('support', 'sample_data_macros')

require 'integrations/award_wallet/api_client'
require 'integrations/award_wallet/error'

# mutation testing passing as of 8/Mar/17
RSpec.describe Integrations::AwardWallet::APIClient do
  include AwardWalletMacros
  include SampleDataMacros

  stub_award_wallet_api_key!

  describe '.connected_user' do
    let(:json) { sample_json('award_wallet_user') }
    before { stub_award_wallet_api(json) }

    example '' do
      result = described_class.connected_user(12345)

      expect(result['user_id']).to eq 12345
      expect(result['full_name']).to eq 'John Smith'
      expect(result['status']).to eq 'Free'
      expect(result['user_name']).to eq 'JSmith'
      expect(result['email']).to eq 'JSmith@email.com'
      expect(result['forwarding_email']).to eq 'JSmith@AwardWallet.com'
      expect(result['access_level']).to eq 'Regular'
      expect(result['connection_type']).to eq 'Connected'
      expect(result['accounts_access_level']).to eq 'Full control'
      expect(result['accounts_shared_by_default']).to eq true
      expect(result['edit_connection_url']).to eq \
        'https://business.awardwallet.com/members/connection/112233'
      expect(result['account_list_url']).to eq \
        'https://business.awardwallet.com/account/list#/?agentId=112232'
      expect(result['timeline_url']).to eq \
        'https://business.awardwallet.com/timeline/?agentId=166765#/112233'
      expect(result['booking_requests_url']).to eq \
        'https://business.awardwallet.com/awardBooking/queue?user_filter=332211'

      expect(result['accounts'].length).to eq 3

      account_keys = %w[
        account_id display_name kind login autologin_url update_url edit_url
        balance balance_raw owner error_code last_detected_change
        expiration_date last_retrieve_date last_change_date properties history
      ]

      expect(result['accounts'][0].keys).to match_array(account_keys)
      expect(result['accounts'][1].keys).to match_array(account_keys)
      expect(result['accounts'][2].keys).to match_array(
        [*account_keys, 'error_message'],
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
  end # .connected_user

  describe '.account' do
    let(:json) { sample_json('award_wallet_account') }
    before { stub_award_wallet_api(json) }

    example '' do
      result = described_class.connected_user(12345)
      expect(result['account_id']).to eq 7654321
      expect(result['display_name']).to eq 'British Airways (Executive Club)'
      expect(result['kind']).to eq 'Airlines'
      expect(result['login']).to eq 'johnsmith'
      expect(result['autologin_url']).to eq \
        'https://business.awardwallet.com/account/redirect.php?ID=7654321'
      expect(result['update_url']).to eq \
        'https://business.awardwallet.com/account/edit/7654321?autosubmit=1'
      expect(result['edit_url']).to eq \
        'https://business.awardwallet.com/account/edit/7654321'
      expect(result['balance']).to eq '146,780'
      expect(result['balance_raw']).to eq 146780
      expect(result['owner']).to eq 'John Smith'
      expect(result['error_code']).to eq 2
      expect(result['error_message']).to eq 'invalid credentials'
      expect(result['last_detected_change']).to eq '+750'
      expect(result['expiration_date']).to eq '2018-12-10T00:00:00+00:00'
      expect(result['last_retrieve_date']).to eq '2016-01-15T00:00:00+00:00'
      expect(result['last_change_date']).to eq '2016-01-15T00:49:33+00:00'
    end
  end

  context 'when AWARD_WALLET_API_KEY is not set in the env' do
    before do
      @old_api_key = ENV['AWARD_WALLET_API_KEY']
      ENV['AWARD_WALLET_API_KEY'] = nil
    end

    after { ENV['AWARD_WALLET_API_KEY'] = @old_api_key }

    it 'raises an error' do
      expect do
        described_class.connected_user(12345)
      end.to raise_error Integrations::AwardWallet::Error

      expect do
        described_class.account(12345)
      end.to raise_error Integrations::AwardWallet::Error
    end
  end
end
