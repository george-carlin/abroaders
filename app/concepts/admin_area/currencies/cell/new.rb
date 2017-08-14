module AdminArea::Currencies
  module Cell
    # @!method self.call(currency, options = {})
    #   @option options [Reform::Form] form
    class New < Abroaders::Cell::Base
      option :form

      def title
        'New Currency'
      end

      subclasses_use_parent_view!

      private

      def form_tag(&block)
        form_for [:admin, form], &block
      end
    end
  end
end
