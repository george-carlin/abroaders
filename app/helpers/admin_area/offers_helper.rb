module AdminArea
  module OffersHelper
    def options_for_offer_condition_select(offer)
      options_for_select(
        [
          ['Approval', 'on_approval'],
          ['First purchase', 'on_first_purchase'],
          ['Minimum spend', 'on_minimum_spend'],
        ],
        offer.condition,
      )
    end

    def options_for_offer_partner_select(offer)
      options_for_select(
        Offer::Partners.options[:values].map do |key|
          [Partner::Cell::FullName.(key), key]
        end,
        offer.partner,
      )
    end
  end
end
