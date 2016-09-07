require_relative "../record_on_page"

module AdminArea
  class RecommendableOfferOnPage < RecordOnPage
    alias_method :offer, :model

    delegate :card, to: :offer

    button :cancel
    button :confirm
    button :recommend

    def dom_id
      super(:admin_recommend)
    end

  end
end
