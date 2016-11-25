require_relative "../record_on_page"

class CardOnPage < RecordOnPage
  alias card model

  button :confirm
  button :cancel

  # =================================================
  # These methods pertain to elements which are only relevant to certain
  # recommendation statuses, but keep them in the superclass so that other specs
  # can test that the elements are *not* present:

  button :decline,      "No Thanks"
  button :i_applied,    "I applied"
  button :i_called,     proc { "I called #{card.product.bank.name}" }
  button :i_heard_back, "I heard back from the bank"

  def has_apply_btn?
    # The apply 'button' is actually a link styled like a button:
    has_link? "Apply", href: apply_recommendation_path(card)
  end

  def has_no_apply_btn?
    # The apply 'button' is actually a link styled like a button:
    has_no_link? "Apply", href: apply_recommendation_path(card)
  end

  # =================================================

  def has_info_for_a_survey_card?
    has_basic_info = has_content?("Card Name: #{product.name}") &&
                     has_content?("Bank: #{product.bank_name}") &&
                     has_content?("Open") &&
                     has_content?(card.opened_at.strftime("%b %Y")) &&
                     has_no_apply_or_decline_btns?

    if card.closed_at.present?
      has_basic_info &&
        has_content?("Closed") &&
        has_content?(card.closed_at.strftime("%b %Y"))
    else
      has_basic_info && has_no_content?("Closed")
    end
  end

  def has_no_apply_or_decline_btns?
    has_no_apply_btn? && has_no_decline_btn?
  end

  delegate :product, to: :card
end
