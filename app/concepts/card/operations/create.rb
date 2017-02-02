class Card < ApplicationRecord
  module Operations
    class Create < Trailblazer::Operation
      # specify the full name of 'New' to avoid an ugly collision; see
      # https://github.com/trailblazer/trailblazer/issues/168. This can
      # be changed here once the fix to #168 has been released.
      step Nested(::Card::Operations::New)
      step Contract::Validate(key: :card)
      success :sanity_check!
      step Contract::Persist()

      private

      # the HTML form should disable the 'closed_at' input(s) when 'closed' is
      # unchecked, so that closed_at only gets included in the params when it's
      # needed - but be defensive here anywhere.
      def sanity_check!(opts)
        contract = opts['contract.default']
        raise 'this should never happen' if !contract.closed && !contract.closed_at.nil?
      end
    end
  end
end
