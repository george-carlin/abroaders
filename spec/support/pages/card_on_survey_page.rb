require_relative "./record_on_page"

class CardOnSurveyPage < RecordOnPage
  alias_attribute :card, :model

  check_box :opened, Proc.new { "cards_survey_#{id}_card_account_opened" }
  check_box :closed, Proc.new { "cards_survey_#{id}_card_account_closed" }

  field :closed_at_month, Proc.new { "cards_survey_#{id}_card_account_closed_at_month" }
  field :closed_at_year,  Proc.new { "cards_survey_#{id}_card_account_closed_at_year" }
  field :opened_at_month, Proc.new { "cards_survey_#{id}_card_account_opened_at_month" }
  field :opened_at_year,  Proc.new { "cards_survey_#{id}_card_account_opened_at_year" }

end
