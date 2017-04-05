module AdminArea
  module People
    module Operation
      # param:
      #   id: the person's ID
      class Show < Trailblazer::Operation
        step :load_person!
        step :set_offers!

        private

        def load_person!(opts, params:, **)
          opts['person'] = Person.includes(
            unpulled_cards: { product: :bank },
          ).find(params[:id])
        end

        def set_offers!(opts)
          opts['offers'] = Offer.includes(product: [:bank, :currency]).live
        end
      end
    end
  end
end
