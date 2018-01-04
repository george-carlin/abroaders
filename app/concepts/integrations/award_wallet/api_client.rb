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
    #
    # NOTE: Since October 2017, the AwardWallet API only accepts requests from
    # a whitelist of IPs. Since Heroku apps don't normally have static IPs,
    # I've had to use an add-on called Fixie (https://elements.heroku.com/addons/fixie)
    # to simulate them. The IPs used by the live app are:
    #
    #   54.173.229.200
    #   54.175.230.252
    #
    # If you're doing development work using the AW API, you'll probably
    # want to add your own local IP to the whitelist too. You can do it here:
    #
    # https://business.awardwallet.com/profile/api
    class APIClient
      include HTTParty

      base_uri 'https://business.awardwallet.com/api/export/v1'

      logger Rails.logger, :debug, :curl

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
          options = { headers: { 'X-Authentication' => api_key } }
          if Rails.env.production?
            fixie = URI.parse ENV['FIXIE_URL']
            options.merge!(
              http_proxyaddr: fixie.host,
              http_proxyport: fixie.port,
              http_proxyuser: fixie.user,
              http_proxypass: fixie.password
            )
          end
          response = JSON.parse(get(path, options).body)
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
