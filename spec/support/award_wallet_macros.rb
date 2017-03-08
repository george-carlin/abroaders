module AwardWalletMacros
  Response = Struct.new(:body)

  def self.included(base)
    base.extend ClassMethods
  end

  def stub_award_wallet_api(json)
    response = Response.new(json)
    allow(Integrations::AwardWallet::APIClient).to receive(:get).and_return(response)
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
