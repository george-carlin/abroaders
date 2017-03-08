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

  def self.unstub_award_wallet_api_key!
    before do
      @old_api_key = ENV['AWARD_WALLET_API_KEY']
      ENV['AWARD_WALLET_API_KEY'] = nil
    end

    after { ENV['AWARD_WALLET_API_KEY'] = @old_api_key }
  end

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
        'https://business.awardwallet.com/account/list#/?agentId=112233'
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

    context 'when AWARD_WALLET_API_KEY is not set in the env' do
      unstub_award_wallet_api_key!

      it 'raises an error' do
        expect do
          described_class.connected_user(12345)
        end.to raise_error Integrations::AwardWallet::Error
      end
    end
  end # .connected_user
end
