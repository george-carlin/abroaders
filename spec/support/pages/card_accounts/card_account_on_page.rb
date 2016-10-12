require_relative "../record_on_page"

class CardAccountOnPage < RecordOnPage
  alias card_account model

  button :confirm
  button :cancel

  # =================================================
  # These methods pertain to elements which are only relevant to certain
  # recommendation statuses, but keep them in the superclass so that other specs
  # can test that the elements are *not* present:

  button :decline,      "No Thanks"
  button :i_applied,    "I applied"
  button :i_called,     proc { "I called #{card_account.card.bank.name}" }
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

  def has_info_for_a_survey_card?
    has_basic_info = has_content?("Card Name: #{card.name}") &&
                      has_content?("Bank: #{card.bank_name}") &&
                      has_content?("Open") &&
                      has_content?(card_account.opened_at.strftime("%b %Y")) &&
                      has_no_apply_or_decline_btns?

    if card_account.closed_at.present?
      has_basic_info &&
        has_content?("Closed") &&
        has_content?(card_account.closed_at.strftime("%b %Y"))
    else
      has_basic_info && has_no_content?("Closed")
    end
  end

  def has_apply_and_decline_btns?
    has_apply_btn? && has_decline_btn?
  end

  def has_no_apply_or_decline_btns?
    has_no_apply_btn? && has_no_decline_btn?
  end

  private

  delegate :card, to: :card_account
end
