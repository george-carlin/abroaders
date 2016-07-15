require_relative "../record_on_page"

class CardAccountOnPage < RecordOnPage
  alias_method :card_account, :model

  button :confirm
  button :cancel

  # =================================================
  # These methods pertain to elements which are only relevant to certain
  # recommendation statuses, but keep them in the superclass so that other specs
  # can test that the elements are *not* present:

  button :decline,      "No Thanks"
  button :i_applied,    "I applied"
  button :i_called,     Proc.new { "I called #{card_account.card.bank.name}" }
  button :i_heard_back, "I heard back from the bank"

  def has_apply_btn?
    # The apply 'button' is actually a link styled like a button:
    has_link? "Apply", href: apply_card_recommendation_path(card_account)
  end

  def has_no_apply_btn?
    # The apply 'button' is actually a link styled like a button:
    has_no_link? "Apply", href: apply_card_recommendation_path(card_account)
  end

  # =================================================

end
