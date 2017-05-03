module AdminArea
  module CardProductsHelper
    def options_for_card_network_select(selected_network)
      options_for_select(
        CardProduct::Network.values.map do |network|
          [CardProduct::Cell::Network::NAMES.fetch(network.to_sym), network]
        end,
        selected_network,
      )
    end

    def options_for_card_type_select(selected_type)
      options_for_select(
        CardProduct::Type.values.map do |type|
          [CardProduct::Cell::Type::NAMES.fetch(type.to_sym), type]
        end,
        selected_type,
      )
    end
  end
end
