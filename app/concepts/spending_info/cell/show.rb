class SpendingInfo < SpendingInfo.superclass
  module Cell
    class Show < Trailblazer::Cell
      extend Abroaders::Cell::Result

      skill :account
      skill :people

      def initialize(result, options = {})
        unless result['account'].people.any?(&:eligible)
          raise 'account must have >-1 eligible person'
        end
        super
      end

      def title
        'My Financials'
      end

      private

      def financials_for_each_person
        content_tag :div, class: 'row' do
          cell(PersonFinancials, collection: people)
        end
      end

      # @!method self.call(person, options = {}
      #   @param person [Person]
      #   @option options [Boolean] use_name
      class PersonFinancials < Trailblazer::Cell
        include ::Cell::Builder
        include Escaped

        property :first_name

        builds do |person|
          person.eligible ? self : Ineligible
        end

        private

        def financials
          cell(SpendingInfo::Cell::Table, model.spending_info)
        end

        def link_to_edit
          link_to 'Edit', edit_person_spending_info_path(model)
        end

        class Ineligible < self
        end
      end
    end
  end
end
