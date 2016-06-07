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

    def review_all_btn
      btn_classes = "btn btn-lg btn-primary"
      button_to(
          "Done",
          review_all_admin_offers_path,
          class:  "done_btn #{btn_classes} pull-right",
          id:     "done_btn"
      )
    end

  end
end
