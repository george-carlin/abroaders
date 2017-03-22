module AdminArea
  module Accounts
    module Cell
      class Show < Trailblazer::Operation
        success :setup_models

        private

        def setup_models(opts)
          account = Account.find(params[:id])
          opts['account'] = account
          opts['cards'] = account.cards.select(&:persisted?)
          opts['recommendation'] = account.cards.new
          # Use account.cards here instead of opts['cards'] because the latter
          # is an Array, not a Relation, because of `.select(&:persisted?)`
          opts['products'] = CardProduct.where.not(id: account.cards.select(:product_id))
        end
      end
    end
  end
end
