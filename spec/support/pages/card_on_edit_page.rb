require_relative "./record_on_page"

class CardOnEditPage < RecordOnPage
  alias_attribute :card, :model

  check_box :closed, proc { "card_account_closed" }

  field :closed_at_month, proc { "card_account_closed_month" }
  field :closed_at_year,  proc { "card_account_closed_year" }
  field :opened_at_month, proc { "card_account_opened_month" }
  field :opened_at_year,  proc { "card_account_opened_year" }
end
