class TravelPlan < TravelPlan.superclass
  class Update < Trailblazer::Operation
    step Nested(Edit)
    success :add_return_on_key_to_params!
    step Contract::Validate(key: :travel_plan)
    step Contract::Persist()

    private

    # If there is no return_on date, make sure the *key* is present (with
    # value nil) so that the value in the underlying model gets nilified.
    def add_return_on_key_to_params!(params:, **)
      if params[:travel_plan][:type] == 'one_way'
        params[:travel_plan][:return_on] = nil
      end
    end
  end
end
