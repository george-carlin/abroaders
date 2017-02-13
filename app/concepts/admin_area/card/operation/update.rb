module AdminArea
  module Card
    module Operation
      class Update < Trailblazer::Operation
        step Nested(Edit)
        step Contract::Validate(key: :card)
        success :sanitize_closed_at!
        step Contract::Persist()

        private

        # Make sure that the card's "closed_at" timestamp is set to nil if
        # the 'closed' checkbox wasn't checked
        def sanitize_closed_at!(options, params:, **)
          # FIXME technical debt ahoy
          unless Dry::Types::Coercions::Form::TRUE_VALUES.include?(params[:card][:closed].to_s)
            options['contract.default'].closed_at = nil
          end
        end
      end
    end
  end
end
