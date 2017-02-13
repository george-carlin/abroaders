class TravelPlan < ApplicationRecord
  module Operation
    class Destroy < Trailblazer::Operation
      step :setup_model!
      step :destroy_travel_plan!
      failure :raise_error!

      private

      def setup_model!(opts, params:, account:, **)
        opts['model'] = account.travel_plans.find(params[:id])
      end

      def destroy_travel_plan!(_opts, model:, **)
        model.destroy!
      end

      def raise_error!(*)
        raise 'an unknown error occurred' # this should never happen
      end
    end
  end
end
