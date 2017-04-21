module AdminArea::Banks
  module Cell
    # @!method self.call(banks, options = {})
    #   @param banks [Collection<Bank>]
    class FilterPanel < Abroaders::Cell::Base
      private

      def check_box_tags
        cell(CheckBoxFormGroup, collection: model)
      end

      # @!method self.call(bank, options)
      #   @param bank [Bank]
      class CheckBoxFormGroup < Abroaders::Cell::Base
        property :id
        property :name

        def show
          html_id = "card_bank_filter_#{id}"
          label_tag html_id do
            check_box_tag(
              html_id,
              nil,
              true,
              class: 'card_bank_filter',
              data: { key: :bank, value: id },
            ) << raw("&nbsp;&nbsp#{name} #{only_btn}")
          end
        end

        private

        def only_btn
          button_tag(
            'Only',
            id: "card_bank_filter_#{id}_only",
            class: 'btn-link btn-xs card_bank_only_filter',
            data: { key: :bank, value: id },
          )
        end
      end
    end
  end
end
