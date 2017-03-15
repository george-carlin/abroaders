class Balance < Balance.superclass
  module Cell
    class List < Abroaders::Cell::Base
      def show
        content_tag :ul, class: 'person-balances' do
          cell(ListItem, collection: model)
        end
      end
    end

    class ListItem < Abroaders::Cell::Base
      include ActionView::Helpers::NumberHelper

      property :currency
      property :value

      private

      def html_id
        dom_id(currency)
      end

      delegate :name, to: :currency, prefix: true

      def value
        number_with_delimiter(super)
      end
    end
  end
end
