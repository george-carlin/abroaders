require_relative "../model_on_page"

class CardAccountOnPage < ModelOnPage
  alias_method :card_account, :model

  button :approved,  "I was approved"
  button :decline,   "No Thanks"
  button :confirm,   "Confirm"
  button :cancel,    "Cancel"
  button :denied,    "My application was denied"
  button :i_applied, "I applied"
  button :pending,   "I'm waiting to hear back"

  field :approved_at,    "card_account_opened_at"
  field :decline_reason, "card_account_decline_reason"

  def decline_reason_wrapper
    find("#" << decline_reason).find(:xpath, '..')
  end

  def has_apply_btn?
    # The apply 'button' is actually a link styled like a button:
    has_link? "Apply", href: apply_card_recommendation_path(card_account)
  end

  def has_no_apply_btn?
    # The apply 'button' is actually a link styled like a button:
    has_no_link? "Apply", href: apply_card_recommendation_path(card_account)
  end

  def set_approved_at_to(date)
    find("#" << approved_at).click
    day = date.strftime("%e").strip
    find(".datepicker .day:not(.old)", text: day).click
  end

end
