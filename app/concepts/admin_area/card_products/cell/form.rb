module AdminArea
  module CardProducts
    module Cell
      # The <form> tag on both the Edit and New pages
      #
      # @!method self.call(card_product, options = {})
      class Form < Abroaders::Cell::Base
        private

        def form_tag(&block)
          form_for [:admin, model], &block
        end

        def options_for_network_select
          options_for_select(
            CardProduct::Network.values.map do |network|
              [CardProduct::Cell::Network::NAMES.fetch(network.to_sym), network]
            end,
            model.network,
          )
        end

        def options_for_type_select
          options_for_select(
            CardProduct::Type.values.map do |type|
              [CardProduct::Cell::Type::NAMES.fetch(type.to_sym), type]
            end,
            model.type,
          )
        end
      end
    end
  end
end
