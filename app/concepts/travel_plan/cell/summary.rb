class TravelPlan < TravelPlan.superclass
  module Cell
    # Overview of the entire travel plan, displaying as much data as possible
    # in a small area.
    #
    # At the time of writing, this cell is used on:
    #
    # - admin/people#show
    # - accounts#dashboard
    # - travel_plans#index
    #
    # @!method self.call(model, opts = {})
    #   @param model [TravelPlan]
    #   @option opts [String] well (true) when true, the outermost `<div`> in
    #     the rendered HTML will have the CSS class `well`.
    class Summary < Abroaders::Cell::Base
      include Escaped

      property :id
      property :further_information
      property :one_way?
      property :type

      option :current_admin, optional: true
      alias current_admin? current_admin

      def self.flight_summary_cell
        Flight::Cell::Summary
      end

      private

      def acceptable_classes
        cell AcceptableClasses, model
      end

      def dates
        cell Dates, model
      end

      # See comment in TravelPlan::Edit about old-style TPs being uneditable.
      def editable?
        !current_admin? && model.editable?
      end

      def flight
        model.flights[0]
      end

      def flight_summary
        cell(self.class.flight_summary_cell, flight)
      end

      def html_classes
        "travel_plan #{'well' if options.fetch(:well, true)}"
      end

      def further_information
        "Notes: #{super}" if super.present?
      end

      def link_to_destroy
        link_to(
          'Delete',
          travel_plan_path(id),
          class: 'btn btn-primary btn-xs',
          method: :delete,
          data: {
            confirm: 'Are you sure? You cannot undo this action',
          },
        )
      end

      def link_to_edit
        link_to(
          'Edit',
          edit_travel_plan_path(id),
          class: 'btn btn-primary btn-xs',
        )
      end

      def no_of_passengers
        content_tag :span, class: 'travel_plan_no_of_passengers' do
          "#{fa_icon('male')} &times; #{model.no_of_passengers}"
        end
      end

      def type
        one_way? ? 'One-way' : 'Round trip'
      end

      # A <span>: 'Departure: MM/DD/YYYY Return: MM/DD/YYYY'
      class Dates < Abroaders::Cell::Base
        property :depart_on
        property :return_on
        property :round_trip?
        property :type

        private

        %w[depart_on return_on].each do |date|
          define_method date do
            super().strftime('%D')
          end
        end

        # some legacy TPs have type 'round_trip' but no return_on date:
        def return_date?
          round_trip? && !model.return_on.nil?
        end
      end
    end
  end
end
