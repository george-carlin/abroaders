require_relative 'sample_data_macros'

module AwardWalletMacros
  Response = Struct.new(:body)

  def self.included(base)
    base.extend ClassMethods
    base.include SampleDataMacros
  end

  def stub_award_wallet_api(json)
    response = Response.new(json)
    allow(Integrations::AwardWallet::APIClient).to receive(:get).and_return(response)
  end

  def get_award_wallet_user_from_callback(account)
    result = Integrations::AwardWallet::Callback.(
      { userId: 12345 },
      'account' => account,
      # don't enqueue a real BG job:
      'load_user.job' => double(perform_later: nil),
    )
    raise unless result.success? # sanity check
    result['model']
  end

  def refresh_award_wallet_user_from_sample_data(user)
    op = Integrations::AwardWallet::User::Refresh
    result = op.(
      { user: user },
      'api' => double(connected_user: parsed_sample_json('award_wallet_user')),
    )
    raise unless result.success? # sanity check
    result['model']
  end

  # create example AwardWalletUser by mimicking the real flow of operations
  def setup_award_wallet_user_from_sample_data(account)
    user = get_award_wallet_user_from_callback(account)
    refresh_award_wallet_user_from_sample_data(user)
  end

  module ClassMethods
    def stub_award_wallet_api_key!
      return if ENV['AWARD_WALLET_API_KEY']

      before do
        @old_api_key = ENV['AWARD_WALLET_API_KEY']
        ENV['AWARD_WALLET_API_KEY'] = 'abcdefg'
      end

      after { ENV['AWARD_WALLET_API_KEY'] = @old_api_key }
    end
  end
end
