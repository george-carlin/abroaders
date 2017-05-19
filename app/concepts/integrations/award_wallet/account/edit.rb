module Integrations::AwardWallet
  module Account
    class Edit < Trailblazer::Operation
      extend Contract::DSL

      step :setup_model!
      step Contract::Build()

      contract do
        feature Reform::Form::Coercion
        feature Reform::Form::Dry

        property :balance, type: Types::Form::Int

        validation do
          required(:balance).filled(:int?, gteq?: 0, lteq?: POSTGRESQL_MAX_INT_VALUE)
        end
      end

      def setup_model!(opts, account:, params:, **)
        opts['model'] = account.award_wallet_accounts.find(params.fetch(:id))
      end
    end
  end
end
