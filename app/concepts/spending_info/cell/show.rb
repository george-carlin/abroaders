class SpendingInfo < SpendingInfo.superclass
  module Cell
    class Show < Abroaders::Cell::Base
      def initialize(account, options = {})
        super
        unless eligible_people.any?
          raise 'account must have >= 1 eligible person'
        end
      end

      property :eligible_people
      property :people

      def title
        'My Financials'
      end

      private

      def financials_for_each_person
        content_tag :div, class: 'row' do # owner first:
          cell(PersonFinancials, collection: people.sort_by(&:type).reverse)
        end
      end

      # @!method self.call(person, options = {}
      #   @param person [Person]
      #   @option options [Boolean] use_name
      class PersonFinancials < Abroaders::Cell::Base
        include ::Cell::Builder
        include Escaped

        property :first_name
        property :spending_info

        builds do |person|
          person.eligible ? self : Ineligible
        end

        subclasses_use_parent_view!

        private

        def body
          cell(SpendingInfo::Cell::Table, spending_info)
        end

        def editable?
          true
        end

        def link_to_edit
          link_to 'Edit', edit_person_spending_info_path(model)
        end

        def wrapper(&block)
        end

        class Ineligible < self
          def editable?
            false
          end

          def body
            <<-HTML
              <p>You told us that #{first_name} is not eligible to apply for
              credit cards in the U.S., so we don't need to know his/her
              financial information.</p>
            HTML
          end
        end
      end
    end
  end
end
