module Integrations
  module AwardWallet
    module User
      # Update an AwardWalletUser and its associated AwardWalletAccounts
      # with the latest data from the AwardWallet API.
      #
      # This will be usually run as a background job, via the nested `Job`
      # class, which is just a thin ApplicationJob wrapper around the
      # Trailblazer operation.
      #
      # Since this job will run in the background (or from a rake task), it
      # has no concept of a currently logged-in user. It's up to the
      # controller layer to make sure that users can only refresh their own
      # AwardWallet data (i.e. they can only schedule the BG job with their
      # own award wallet user ID)
      #
      # @!method self.call(params, options = {})
      #   @option params [AwardWalletUser] user
      #   @return [Trailblazer::Result]
      class Refresh < Trailblazer::Operation
        self['api'] = APIClient
        self['update_op'] = User::Update

        step Wrap(Abroaders::Transaction) {
          step :get_data_from_api
          step :update_user
          step :update_accounts
          step :delete_old_accounts_and_owners
          failure :rollback
        }

        private

        def get_data_from_api(opts, params:, **)
          user = params.fetch(:user)
          opts['user_data'] = self['api'].connected_user(user.aw_id)
        end

        def update_user(opts, params:, user_data:, **)
          user = params.fetch(:user)
          result = self['update_op'].(user: user, data: user_data)
          opts['model'] = result['model']
          result.success?
        end

        def update_accounts(model:, user_data:, **)
          user_data.fetch('accounts').all? do |data|
            Account::Save.(user: model, account_data: data).success?
          end
        end

        # delete any AwardWalletAccounts or AwardWalletOwners which belong to
        # the AwardWalletUser but aren't contained in the API data anymore.
        def delete_old_accounts_and_owners(model:, user_data:, **)
          accounts_data = user_data.fetch('accounts')
          owner_names = accounts_data.map { |acc| acc.fetch('owner') }
          account_ids = accounts_data.map { |acc| acc.fetch('account_id') }

          model.award_wallet_owners.where.not(name: owner_names).destroy_all
          model.award_wallet_accounts.where.not(aw_id: account_ids).destroy_all
        end

        def rollback(*)
          raise ActiveRecord::Rollback
        end

        class All
          def self.call
            # This approach isn't perfect as it results in a TON of DB queries;
            # we can probably improve it with some eager-loading... later.
            # (Putting 'includes(:award_wallet_owners, :award_wallet_accounts)'
            # in the AwardWalletUser.find_each doesn't work, I already tried
            # it. Them problem is in the Account::Save class.)
            AwardWalletUser.find_each do |awu|
              begin
                Refresh.(user: awu)
              rescue AwardWallet::Error => e
                "Couldn't refresh user #{awu.id}: #{e.message}"
              end
            end
          end
        end

        class Job < ApplicationJob
          queue_as :award_wallet

          # @param opts [Hash]
          # @option opts [Integer] 'id' the ID of the AwardWalletUser to
          #   refresh
          def perform(opts = {})
            id = opts.fetch('id')
            Refresh.(user: AwardWalletUser.find(id))
          end
        end
      end
    end
  end
end
