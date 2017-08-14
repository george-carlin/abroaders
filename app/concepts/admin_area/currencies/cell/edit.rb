module AdminArea::Currencies
  module Cell
    # @!method self.call(currency, options = {})
    #   @option options [Reform::Form] form
    class Edit < New
      option :form

      def title
        'Edit Currency'
      end
    end
  end
end
