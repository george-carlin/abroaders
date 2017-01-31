class Card < ApplicationRecord
  module Operations
    class Create < Trailblazer::Operation
      # specify the full name of 'New' to avoid an ugly collision; see
      # https://github.com/trailblazer/trailblazer/issues/168. This can
      # be changed here once the fix to #168 has been released.
      step Nested(::Card::Operations::New)
      step Contract::Validate(key: :card)
      step Contract::Persist()
    end
  end
end
