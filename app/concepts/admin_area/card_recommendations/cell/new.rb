require 'abroaders/cell/options'

module AdminArea
  module CardRecommendations
    module Cell
      class New < Trailblazer::Cell
        extend Abroaders::Cell::Options

        option :offer
        option :person

        private

        def cancel_recommend_btn
          prefix = :cancel_recommend
          button_tag(
            'Cancel',
            class: "#{prefix}_offer_btn #{BTN_CLASSES} btn-default pull-right",
            id:    "#{prefix}_offer_#{offer.id}",
          )
        end

        def confirm_recommend_btn
          button_to(
            'Confirm',
            admin_person_card_recommendations_path(person),
            class:  "#{dom_class(offer, :confirm_recommend)}_btn #{BTN_CLASSES} btn-primary pull-right",
            id:     "#{dom_id(offer, :confirm_recommend)}_btn",
            remote: true,
            params: { card_recommendation: { offer_id: offer.id } },
          )
        end

        BTN_CLASSES = 'btn btn-xs'.freeze

        def recommend_btn
          button_tag(
            'Recommend',
            class: "#{dom_class(offer, :recommend)}_btn #{BTN_CLASSES} btn-primary pull-right",
            id:    "#{dom_id(offer, :recommend)}_btn",
          )
        end
      end
    end
  end
end
