module AdminArea::Currencies
  module Cell
    # model: Currency
    class New < Abroaders::Cell::Base
      option :form

      def title
        'New Currency'
      end

      private

      def form_tag(&block)
        form_for [:admin, form], &block
      end
    end
  end
end
