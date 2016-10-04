require_relative "./record_on_page"

class CardOnNewPage < RecordOnPage
  alias_attribute :card, :model

  check_box :closed, Proc.new { "card_card_account_closed" }

  field :closed_at_month, Proc.new { "card_card_account_closed_month" }
  field :closed_at_year,  Proc.new { "card_card_account_closed_year" }
  field :opened_at_month, Proc.new { "card_card_account_opened_month" }
  field :opened_at_year,  Proc.new { "card_card_account_opened_year" }

end
