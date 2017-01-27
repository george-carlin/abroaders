class TravelPlan < ApplicationRecord
  module Operations
    class Destroy < Trailblazer::Operation
      step :setup_model!
      step :destroy_travel_plan!
      failure :raise_error!

      private

      def setup_model!(opts, params:, current_account:, **)
        opts['model'] = current_account.travel_plans.find(params[:id])
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
