class TravelPlan < ApplicationRecord
  module Cell
    # Overview of the entire travel plan, displaying as much data as possible
    # in a small area
    #
    # At the time of writing, this cell is used by:
    #
    # - admin/people#show
    # - accounts#dashboard
    # - travel_plans#index
    class Summary < Trailblazer::Cell
      include ActionView::Helpers::RecordTagHelper
      include FontAwesome::Rails::IconHelper

      alias travel_plan model

      property :further_information
      property :type

      private

      def acceptable_classes
        cell AcceptableClasses, travel_plan
      end

      def dates
        cell Dates, travel_plan
      end

      def flight
        model.flights[0]
      end

      def html_class
        "#{dom_class(travel_plan)} well"
      end

      def html_id
        dom_id(travel_plan)
      end

      def further_information
        "Notes: #{super}" if super.present?
      end

      def no_of_passengers
        content_tag :span, class: 'travel_plan_no_of_passengers' do
          "#{fa_icon('male')} &times; #{travel_plan.no_of_passengers}"
        end
      end

      def type
        super == 'single' ? 'One-way' : 'Round trip'
      end

      # See comment in TravelPlan::Operations::Edit about old-style TPs
      # being uneditable
      def editable?
        ![flight.to.class, flight.from.class].include?(Country)
      end

      # A <span>: 'Departure: MM/DD/YYYY Return: MM/DD/YYYY'
      class Dates < Trailblazer::Cell
        property :depart_on
        property :return_on
        property :type

        private

        %w[depart_on return_on].each do |date|
          define_method date do
            super().strftime('%D')
          end
        end

        # some legacy TPs have type 'return' but no return_on date:
        def return_date?
          type == 'return' && !model.return_on.nil?
        end
      end
    end
  end
end
