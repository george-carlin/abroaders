module AdminArea
  module CardRecommendationsHelper

    def confirm_recommend_card_btn(offer)
      btn_classes = "btn btn-xs btn-primary"
      prefix = :confirm_recommend
      button_to(
        "Confirm",
        admin_user_card_recommendations_path(@user),
        class:  "#{dom_class(offer, prefix)}_btn #{btn_classes} pull-right",
        id:     "#{dom_id(offer, prefix)}_btn",
        params: { offer_id: offer.id }
      )
    end

    def cancel_recommend_card_btn(offer)
      btn_classes = "btn btn-xs btn-default"
      prefix = :cancel_recommend
      button_tag(
        "Cancel",
        class: "#{dom_class(offer, prefix)}_btn #{btn_classes} pull-right",
        id:    "#{dom_id(offer, prefix)}_btn"
      )
    end

    def recommend_card_btn(offer)
      btn_classes = "btn btn-xs btn-primary"
      prefix = :recommend
      button_tag(
        "Recommend",
        class: "#{dom_class(offer, prefix)}_btn #{btn_classes} pull-right",
        id:    "#{dom_id(offer, prefix)}_btn"
      )
    end

  end
end
