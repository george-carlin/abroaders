class Alliance < ApplicationRecord
  module Cell
    class CurrencyFilterPanel < Trailblazer::Cell
      include Recommendation::FilterPanel

      alias alliance model
      property :id
      property :name

      private

      alias title name

      def filter_all_check_box_tag
        check_box_tag(
          "card_currency_alliance_filter_all_for_#{id}",
          nil,
          true,
          class: "toggle-all-currency-checkbox",
        )
      end

      def currency_check_boxes
        alliance.currencies.filterable.order(name: :asc).map do |currency|
          cell(CheckBox, currency)
        end.join
      end

      class CheckBox < Trailblazer::Cell
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
