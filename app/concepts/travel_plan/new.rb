class TravelPlan < TravelPlan.superclass
  class New < Trailblazer::Operation
    extend Contract::DSL

    contract Form

    step :setup_model!
    step Contract::Build()

    private

    def setup_model!(opts, account:, **)
      # DB default for type is 'one_way' but we should change this TODO
      opts['model'] = account.travel_plans.new(type: 'round_trip')
    end
  end
end
