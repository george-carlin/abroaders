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
    #
    # model: a TravelPlan
    # options:
    #   well: whether the outermost div should have the Bootstrap 'well' CSS class. default true
    #   hr:   whether the HTML should have an <hr> on the end. default false
    class Summary < Trailblazer::Cell
      include ActionView::Helpers::RecordTagHelper
      include Escaped
      include FontAwesome::Rails::IconHelper

      alias travel_plan model

      property :id
      property :further_information
      property :type

      private

      def acceptable_classes
        cell AcceptableClasses, travel_plan
      end

      def dates
        cell Dates, travel_plan
      end

      # See comment in TravelPlan::Operations::Edit about old-style TPs
      # being uneditable
      def editable?
        ![flight.to.class, flight.from.class].include?(Country)
      end

      def flight
        model.flights[0]
      end

      def html_classes
        "travel_plan #{'well' if options.fetch(:well, true)}"
      end

      def html_id
        dom_id(travel_plan)
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
          "#{fa_icon('male')} &times; #{travel_plan.no_of_passengers}"
        end
      end

      def type
        super == 'single' ? 'One-way' : 'Round trip'
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
