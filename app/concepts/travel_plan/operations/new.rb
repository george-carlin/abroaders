class TravelPlan < ApplicationRecord
  module Operations
    class New < Trailblazer::Operation
      extend Contract::DSL

      contract TravelPlan::Form

      step :setup_model!
      step Contract::Build()

      private

      def setup_model!(opts, current_account:, **)
        # DB default for type is 'single' but we should change this
        opts['model'] = current_account.travel_plans.new(type: :return)
      end
    end
  end
end
