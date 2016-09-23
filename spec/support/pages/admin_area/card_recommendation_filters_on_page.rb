require_relative "../object_on_page"

module AdminArea
  class CardRecommendationFiltersOnPage < ObjectOnPage

    check_box :business, :card_bp_filter_business
    check_box :personal, :card_bp_filter_personal

    check_box :all_banks, :card_bank_filter_all
    check_box :all_currencies, :card_currency_filter_all
    check_box :chase, Proc.new { "card_bank_filter_#{Bank.find_by_name("Chase").id}" }
    check_box :us_bank, Proc.new { "card_bank_filter_#{Bank.find_by_name("US Bank").id}" }

    def dom_selector
      "#card-recommendation-filters"
    end

    def all_banks_filter
      find("#card_bank_filter_all")
    end

    def all_currencies_filter
      find("#card_currency_filter_all")
    end

  end
end
