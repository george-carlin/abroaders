module Integrations
  module AwardWallet
    module Account
      module Operation
        # Takes an AwardWalletUser and a Hash of data for one of that user's
        # accounts (as pulled from the AwardWallet API). If the account doesn't
        # exist in our DB, creates it. Else, updates the existing account.
        # (Judges whether or not the account already exists by comparing
        # the 'account_id' attribute of the data, which we save in the column
        # `award_wallet_accounts.aw_id`.
        #
        # Looks at the 'Owners' that belong to the AWU and figures out which
        # Owner to assign the account to by comparing the 'owner' column in the
        # data to the 'name' attribute of the existing owners. If no owner
        # exists with the given name, creates it.
        #
        # This operation doesn't validate the data in any way; it just assumes
        # that we've pulled valid data from the AW API.
        #
        # Will mainly be used in BG jobs, so doesn't have a logged-in user.
        #
        # @!method self.call(params, options = {})
        #   @option params [AwardWalletUser] user
        #   @option params [Hash] account_data the following attrs are required:
        #     "account_id"
        #     "balance_raw"
        #     "display_name"
        #     "error_code"
        #     "error_message"
        #     "expiration_date"
        #     "kind"
        #     "last_change_date"
        #     "last_detected_change"
        #     "last_retrieve_date"
        #     "login"
        #     "owner"
        #   Anything else will be ignored.
        class Save < Trailblazer::Operation
          step :set_data_and_user
          step :find_or_initialize_account
          step :find_or_create_owner
          step :create_or_update_account

          private

          def set_data_and_user(opts, params:)
            opts['account_data'] = params.fetch(:account_data)
            opts['user']         = params.fetch(:user)
          end

          def find_or_initialize_account(opts, account_data:, user:, **)
            id = account_data.fetch('account_id')
            opts['model'] = user.award_wallet_accounts
                                .find_or_initialize_by(aw_id: id)
          end

          def find_or_create_owner(opts, account_data:, user:, **)
            name = account_data.fetch('owner')
            opts['owner'] = user.award_wallet_owners.find_or_create_by!(name: name)
          end

          def create_or_update_account(account_data:, model:, owner:, **)
            attrs = account_data.slice(
              'balance_raw', 'display_name', 'error_code', 'error_message', 'expiration_date', 'kind', 'last_change_date', 'last_detected_change', 'last_retrieve_date', 'login',
            )
            attrs['award_wallet_owner'] = owner
            model.update!(attrs)
          end
        end
      end
    end
  end
end
