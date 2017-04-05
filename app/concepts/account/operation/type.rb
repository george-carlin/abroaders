require 'dry-validation'

class Account < Account.superclass
  module Operation
    class Type < Trailblazer::Operation
      success :setup_destination!

      private

      def setup_destination!(opts)
        unless opts['account'].travel_plans.empty?
          opts['model'] = opts['account'].travel_plans[-1].flights[0].to
        end
      end

      class Onboard < Trailblazer::Operation
        # contract: params must have key 'account'. account must have nested
        # key 'type' whose valid values are 'couples' or 'solo'. If
        # type='couples' account must also have key 'companion_first_name',
        # which must be a non-blank string.
        success :raise_if_invalid_params!
        step :create_companion_if_couples!
        step :update_account_onboarding_state!

        private

        # It's impossible to submit invalid params through the regular HTML
        # form, so just raise an error if they've been tinkering with it.
        def raise_if_invalid_params!(_opts, params:, **)
          # I tried to build something fancy using dry-vbut couldn't figure out
          # how to validate that account.companion_first_name is present and
          # non-empty when type=couples. Here's the ugly alternative:
          raise if params[:account].nil?
          raise unless %w[couples solo].include?(params[:account][:type])
          if params[:account][:type] == 'couples'
            raise unless params[:account][:companion_first_name].present?
          end
        end

        def create_companion_if_couples!(opts, params:, **)
          if params[:account][:type] == 'couples'
            name = params[:account][:companion_first_name].strip
            opts['account'].create_companion!(first_name: name)
          end
          true
        end

        def update_account_onboarding_state!(_opts, account:, **)
          Account::Onboarder.new(account).choose_account_type!
          true
        end
      end
    end
  end
end
