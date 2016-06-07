module AdminArea
  module OffersHelper

    def options_for_offer_condition_select(offer)
      options_for_select(
        Offer.conditions.each_with_object({}) do |(key, _), hash|
          hash[t("activerecord.attributes.offer.conditions.#{key}")] = key
        end,
        offer.condition
      )
    end

    def update_offers_last_reviewed_at_btn
      btn_classes = "btn btn-lg btn-primary"
      prefix = :update_offers_last_reviewed_at
      button_to(
          "Done",
          update_offers_last_reviewed_at_admin_offers_path,
          class:  "done_btn #{btn_classes} pull-right",
          id:     "done_btn"
      )
    end

  end
end
