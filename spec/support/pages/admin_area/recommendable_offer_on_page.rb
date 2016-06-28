module AdminArea
  class RecommendableOfferOnPage < ModelOnPage
    alias_method :offer, :model

    delegate :card, to: :offer

    button :cancel,    "Cancel"
    button :confirm,   "Confirm"
    button :recommend, "Recommend"

    def dom_id
      super(:admin_recommend)
    end

  end
end
