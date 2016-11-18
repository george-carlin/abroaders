require_relative "../object_on_page"

module AdminArea
  class CardRecommendationFiltersOnPage < ObjectOnPage
    check_box :business, :card_bp_filter_business
    check_box :personal, :card_bp_filter_personal

    check_box :all_banks, :card_bank_filter_all
    check_box :all_one_world_currencies, proc { "card_currency_alliance_filter_all_for_#{Alliance.find_by_name('OneWorld').id}" }
    check_box :all_sky_team_currencies, proc { "card_currency_alliance_filter_all_for_#{Alliance.find_by_name('SkyTeam').id}" }
    check_box :chase, proc { "card_bank_filter_#{Bank.find_by_name('Chase').id}" }
    check_box :us_bank, proc { "card_bank_filter_#{Bank.find_by_name('US Bank').id}" }

    def dom_selector
      "#card-recommendation-filters"
    end

    def all_one_world_currencies_check_box
      find("#card_currency_alliance_filter_all_for_#{Alliance.find_by_name('OneWorld').id}")
    end
  end
end
