require_relative "../model_on_page"

class CardAccountOnPage < ModelOnPage
  alias_method :card_account, :model

  button :approved,  "I was approved"
  button :decline,   "No Thanks"
  button :confirm,   "Confirm"
  button :cancel,    "Cancel"
  button :denied,    "My application was denied"
  button :i_applied, "I applied"
  button :i_called,     "I called"
  button :i_heard_back, "The bank got back to me before I could call them"
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

  # NOTE: If we start adding other datepickers to the app, and you find
  # yourself semi-duplicating this method elsewhere, it might be a better idea
  # to extract a new Page Object called DatePickerOnPage
  def set_approved_at_to(date)
    find("#" << approved_at).click
    day = date.day.to_s

    # Prevent an infinite loop from occurring in the "until" block below
    if date > Date.today
      raise "error: approved at must be today or in the past"
    end

    # If the date we want to find isn't in the current month, go back through
    # the datepicker months until we find it.
    get_current_month_in_datepicker = -> { Date.parse(find(".datepicker-switch").text) }
    target_month = date.change(day: 1).to_date # drop the time part of the date if it's there

    # Both dates are a Date object where day of the month is the 1st:
    until get_current_month_in_datepicker.call == target_month
      # Go back a month
      find(".datepicker .prev").click
    end
    find(".datepicker .day:not(.old)", text: day).click
  end

end
