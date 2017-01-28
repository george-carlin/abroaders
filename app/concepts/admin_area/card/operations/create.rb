module AdminArea
  module Card
    module Operations
      class Create < Trailblazer::Operation
        # specify the full name of 'New' to avoid an ugly collision; see
        # https://github.com/trailblazer/trailblazer/issues/168
        #
        # (Note: the above issue has been resolved, and the fix should be
        # coming in an upcoming (> 0.0.12) version of trailblazer-operation
        step Nested(AdminArea::Card::Operations::New)
        step Contract::Validate(key: :card)
        step Contract::Persist()
      end
    end
  end
end
