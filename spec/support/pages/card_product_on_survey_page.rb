require_relative "./record_on_page"

class CardProductOnSurveyPage < RecordOnPage
  alias_attribute :product, :model

  check_box :opened, proc { "cards_survey_#{id}_card_account_opened" }
  check_box :closed, proc { "cards_survey_#{id}_card_account_closed" }

  field :closed_at_month, proc { "cards_survey_#{id}_card_account_closed_at_month" }
  field :closed_at_year,  proc { "cards_survey_#{id}_card_account_closed_at_year" }
  field :opened_at_month, proc { "cards_survey_#{id}_card_account_opened_at_month" }
  field :opened_at_year,  proc { "cards_survey_#{id}_card_account_opened_at_year" }
end
