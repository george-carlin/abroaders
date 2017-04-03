module Integrations
  module AwardWallet
    module User
      module Operation
        # Takes an AwardWalletUser and a Hash of data for that user (as pulled
        # from the AwardWallet API), and updates the user (and sets user.loaded
        # to true).
        #
        # The hash will be a Ruby representation of the JSON string that we get
        # from the AwardWallet API.
        #
        # Note that we don't need an operation that *creates* an
        # AwardWalletUser in this way. AWUs are exclusively created through the
        # 'Callback' operation.
        #
        # This operation doesn't validate the data in any way; it just assumes
        # that we've pulled valid data from the AW API.
        #
        # Will mainly be used in BG jobs and so doesn't have a currently-logged
        # in user.
        #
        # @!method self.call(params, options = {})
        #   @option params [AwardWalletUser] user
        #   @option params [Hash] data the following attrs are required:
        #       "access_level"
        #       "accounts_access_level"
        #       "edit_connection_url"
        #       "email"
        #       "forwarding_email"
        #       "full_name"
        #       "status"
        #       "user_name"
        #     Anything else will be ignored. This op also sets the 'agent_id'
        #     attr of the AWU, which it figures out by looking in the
        #     edit_connection_url attr (it's not included as a key in the data
        #     from the API)
        class Update < Trailblazer::Operation
          step :set_model
          step :update!

          private

          def set_model(opts, params:)
            opts['model'] = params.fetch(:user)
          end

          def update!(model:, params:)
            attrs = params.fetch(:data).slice(
              'access_level',
              'account_list_url',
              'accounts_access_level',
              'email',
              'forwarding_email',
              'full_name',
              'status',
              'user_name',
            )
            # The JSON doesn't tell us the 'agentId' directly (there's no key
            # with that name), but it includes the 'account_list_url', which
            # has the agentId as a GET param. The 'edit_connection_url' doesn't
            # contain the string 'agentId', but it ends with a number that's
            # equal to (1 + the agentId from the other URL).
            url = attrs.delete('account_list_url')
            attrs['agent_id'] = Rack::Utils.parse_query(url.split('#')[-1][2..-1])['agentId']
            attrs['loaded']   = true
            model.update!(attrs)
          end
        end
      end
    end
  end
end
