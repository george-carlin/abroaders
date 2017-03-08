module AwardWalletMacros
  Response = Struct.new(:body)

  def stub_award_wallet_api(json)
    response = Response.new(json)
    allow(Integrations::AwardWallet::APIClient).to receive(:get).and_return(response)
  end
end
