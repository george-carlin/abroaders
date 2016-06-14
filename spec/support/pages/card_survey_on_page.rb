class CardSurveyOnPage < ObjectOnPage

  def dom_selector
    ".content"
  end

  def click_back
    within_self { click_button "Back" }
  end

  def click_confirm
    within_self { click_button "Confirm" }
  end

  def click_no
    within_self { click_button "No" }
  end

  def click_yes
    within_self { click_button "Yes" }
  end

  class Card < ModelOnPage
    alias_attribute :card, :model

    check_box :opened, Proc.new { "cards_survey_#{id}_card_account_opened" }
    check_box :closed, Proc.new { "cards_survey_#{id}_card_account_closed" }

    field :closed_at_month, Proc.new { "cards_survey_#{id}_card_account_closed_at_month" }
    field :closed_at_year,  Proc.new { "cards_survey_#{id}_card_account_closed_at_year" }
    field :opened_at_month, Proc.new { "cards_survey_#{id}_card_account_opened_at_month" }
    field :opened_at_year,  Proc.new { "cards_survey_#{id}_card_account_opened_at_year" }

  end
end
