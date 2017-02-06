class Person < Person.superclass
  module Cell
    class Dashboard < Trailblazer::Cell
      include ActionView::Helpers::RecordTagHelper

      property :first_name
      property :eligible?

      def self.call(model, *args)
        unless (model.is_a?(Hash) && model[:collection]) || model.account.onboarded?
          raise 'account must be onboarded'
        end
        super
      end

      private

      def balances
        if model.balances.any?
          '<h4>Balances</h4>' << Balance::Cell::List.(model.balances.includes(:currency)).show
        else
          '<p>No existing frequent flyer balances</p>'
        end
      end

      def html_id
        dom_id(model)
      end

      def html_classes
        "#{dom_class(model)} hpanel col-xs-12 col-md-6"
      end

      def link_to_edit_spending
        link_to 'Edit', edit_person_spending_info_path(model)
      end

      def spending_info
        SpendingInfo::Cell::Table.(model.spending_info)
      end
    end
  end
end
