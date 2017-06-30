require 'abroaders/cell/options'

module AdminArea
  module CardRecommendations
    module Cell
      class New < Abroaders::Cell::Base
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
            class: "confirm_recommend_offer_btn #{BTN_CLASSES} btn-primary pull-right",
            id: "confirm_recommend_offer_#{offer.id}_btn",
            remote: true,
            params: { card: { offer_id: offer.id } },
          )
        end

        BTN_CLASSES = 'btn btn-xs'.freeze

        def recommend_btn
          button_tag(
            'Recommend',
            class: "recommend_offer_btn #{BTN_CLASSES} btn-primary pull-right",
            id: "recommend_offer_#{offer.id}_btn",
          )
        end
      end
    end
  end
end
