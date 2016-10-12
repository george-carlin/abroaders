require_relative "./card_account_on_page"

class NewCardAccountOnPage < CardAccountOnPage
  button :approved, "I was approved"
  button :denied,   "My application was denied"
  button :pending,  "I'm waiting to hear back"

  field :approved_at,    "card_account_opened_at"
  field :decline_reason, "card_account_decline_reason"

  def decline_reason_wrapper
    find("#" << decline_reason).find(:xpath, '..')
  end

  # NOTE: If we start adding other datepickers to the app, and you find
  # yourself semi-duplicating this method elsewhere, it might be a better idea
  # to extract a new Page Object called DatePickerOnPage
  def set_approved_at_to(date)
    find("#" << approved_at).click
    day = date.day.to_s

    # Prevent an infinite loop from occurring in the "until" block below
    raise "error: approved at must be today or in the past" if date > Date.today

    # If the date we want to find isn't in the current month, go back through
    # the datepicker months until we find it.
    get_current_month_in_datepicker = -> { Date.parse(find(".datepicker-switch").text) }
    target_month = date.change(day: 1).to_date # drop the time part of the date if it's there

    # Both dates are a Date object where day of the month is the 1st:
    until get_current_month_in_datepicker.call == target_month
      # Go back a month
      find(".datepicker .prev").click
    end
    # Test that text *exactly* matches or e.g. the selector will return the
    # '11' button when searching for '1'.
    find(".datepicker .day:not(.old):not(.disabled)", text: /\A#{day}\z/).click
  end
end
