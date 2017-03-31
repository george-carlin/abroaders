require 'abroaders/cell/options'

class Alliance < Alliance.superclass
  module Cell
    # @!method self.call(alliance, options = {})
    #   @param alliance [Alliance]
    class CurrencyFilterPanel < Abroaders::Cell::Base
      include CardRecommendation::FilterPanel

      property :id
      property :name

      private

      alias title name

      def currencies
        @currencies ||= model.filterable_currencies.order(name: :asc)
      end

      def currency_check_boxes
        cell(CheckBox, collection: currencies)
      end

      def filter_all_check_box_tag
        check_box_tag(
          "card_currency_alliance_filter_all_for_#{id}",
          nil,
          true,
          class: "toggle-all-currency-checkbox",
        )
      end

      class CheckBox < Abroaders::Cell::Base
        property :id

        def show
          label_tag(html_id) do
            check_box_tag(
              html_id,
              nil,
              true,
              class: CSS_CLASS,
              data: { key: :currency, value: id },
            ) << raw("&nbsp;&nbsp#{label_text}")
          end
        end

        private

        def label_text
          Currency::Cell::ShortName.(model).to_s
        end

        CSS_CLASS = 'card_currency_filter'.freeze

        def html_id
          "#{CSS_CLASS}_#{id}"
        end
      end
    end
  end
end
