module AdminArea
  module People
    module Operation
      # param:
      #   id: the person's ID
      class Show < Trailblazer::Operation
        step :load_person
        step :load_card_products

        private

        def load_person(opts, params:, **)
          opts['person'] = Person.includes(
            unpulled_cards: { product: :bank },
            balances: :currency,
          ).find(params[:id])
        end

        def load_card_products(opts)
          opts['card_products'] = CardProduct.includes(
            :bank, :currency, :recommendable_offers,
          ).recommendable
        end
      end
    end
  end
end
