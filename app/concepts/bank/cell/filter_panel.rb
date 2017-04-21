class Bank < Bank.superclass
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
            ) << raw("&nbsp;&nbsp#{name}")
          end
        end
      end
    end
  end
end
