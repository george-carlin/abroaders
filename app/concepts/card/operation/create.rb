class Card < ApplicationRecord
  module Operation
    class Create < Trailblazer::Operation
      step Nested(New)
      step Contract::Validate(key: :card)
      success :sanity_check!
      step Contract::Persist()
      success :enqueue_zapier_webhook!

      private

      def enqueue_zapier_webhook!(_opts, model:, **)
        ZapierWebhooks::Card::Created.enqueue(model)
      end

      # the HTML form should disable the 'closed_on' input(s) when 'closed' is
      # unchecked, so that closed_on only gets included in the params when it's
      # needed - but be defensive here anywhere.
      def sanity_check!(opts)
        contract = opts['contract.default']
        raise 'this should never happen' if !contract.closed && !contract.closed_on.nil?
      end
    end
  end
end
