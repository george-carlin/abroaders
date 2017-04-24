module AdminArea
  module RecommendationsHelper
    def confirm_recommend_card_btn(offer)
      btn_classes = "btn btn-xs btn-primary"
      button_to(
        "Confirm",
        admin_person_card_recommendations_path(@person),
        class:  "confirm_recommend_offer_btn #{btn_classes} pull-right",
        id:     "confirm_recommend_offer_#{offer.id}_btn",
        params: { offer_id: offer.id },
      )
    end

    def cancel_recommend_card_btn(offer)
      btn_classes = "btn btn-xs btn-default"
      button_tag(
        "Cancel",
        class: "cancel_recommend_offer_btn #{btn_classes} pull-right",
        id:    "cancel_recommend_offer_#{offer.id}_btn",
      )
    end

    def recommend_card_btn(offer)
      btn_classes = "btn btn-xs btn-primary"
      button_tag(
        "Recommend",
        class: "recommend_offer_btn #{btn_classes} pull-right",
        id:    "recommend_offer_#{offer.id}_btn",
      )
    end
  end
end
