require 'httparty'
require 'json'

require 'abroaders/util'

module Integrations
  module AwardWallet
    # Thin wrapper around the AwardWallet API. See:
    #
    #   https://business.awardwallet.com/api/account
    #
    # Makes queries to the API, gets JSON responses, logs that JSON (not
    # yet implemented), and returns the response parsed into a Hash. (The JSON
    # from the API uses camelCased key names, but this class will convert them
    # into underscored keys.
    #
    # Right now we're only implementing the 'connected_user' endpoint, because
    # it's the only one we actually need for the time being, but it should be
    # trivial to implement new endpoints in future.
    #
    # Note that the returned hash will have string keys, not symbol keys
    class APIClient
      include HTTParty

      base_uri 'https://business.awardwallet.com/api/export/v1'

      class << self
        # Takes the userID of an award wallet user (which we get when they grant
        # us permission to view their account data), queries the AW API, and
        # returns the data about that user.
        #
        # userId must belong to a user who has granted us permission to view
        # their AwardWallet data.
        #
        # @raise [Integrations::AwardWallet::Error] if the AW API returns an error
        def connected_user(award_wallet_id)
          query("/connectedUser/#{award_wallet_id}")
        end

        # Takes the userID of an award wallet account, queries the AW API, and
        # returns the data about that account.
        #
        # the account must belong to an AwardWallet user who has granted us
        # permission to view their data.
        #
        # @raise [Integrations::AwardWallet::Error] if the AW API returns an error
        def account(award_wallet_id)
          query("/account/#{award_wallet_id}")
        end

        private

        def query(path)
          raw_response = get(
            path,
            headers: { 'X-Authentication' => api_key },
          ).body
          response = JSON.parse(raw_response)
          raise(Error, response.fetch('error')) if response['error']
          Abroaders::Util.underscore_keys(response, true)
        end

        def api_key
          if ENV['AWARD_WALLET_API_KEY'].nil?
            raise Error, 'AWARD_WALLET_API_KEY env variable not set'
          else
            ENV['AWARD_WALLET_API_KEY']
          end
        end
      end
    end
  end
end
