class TravelPlan < ApplicationRecord
  module Operation
    # Find a Card by its ID, and prepare to edit it
    class Edit < Trailblazer::Operation
      extend Contract::DSL
      contract TravelPlan::Form

      step :setup_model!
      step :assert_plan_is_new_style!
      step Contract::Build()

      private

      def setup_model!(options, params:, **)
        options['model'] = scope.find(params[:id])
      end

      # Where to search for the travel plan. Must return an object which
      # responds to `find`. By default, returns the account's travel
      # plans, but you can override this with the 'travel_plan_scope' skill
      # (e.g. you could set it to `TravelPlan` if you want to search *all*
      # travel plans for an admin action.)
      def scope(*)
        self['scope'] || self['account'].travel_plans
      end

      # In the early days of the app, users created travel plans that were to
      # and from specific *countries*, but nowadays you can only create a
      # travel plan that's from an airport to an airport. Unfortunately, this
      # means that editing an old-style travel plan would require a different
      # form to editing a new-style travel plan. Since very few travel plans in
      # the prod. DB are using this old-style, we're just making them
      # uneditable for now. (This should be handled in the view layer by just
      # never showing them the edit link in the first place, but this method
      # exists as a failsafe against programmer error.)
      def assert_plan_is_new_style!(model:, **)
        flight = model.flights[0]
        if [flight.to.class, flight.from.class].include?(Country)
          raise "uneditable travel plan"
        end
        true
      end
    end
  end
end
