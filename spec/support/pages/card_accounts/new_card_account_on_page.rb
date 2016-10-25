require_relative './card_account_on_page'
require_relative '../../datepicker_macros'

class NewCardAccountOnPage < CardAccountOnPage
  include DatepickerMacros

  button :approved, "I was approved"
  button :denied,   "My application was denied"
  button :pending,  "I'm waiting to hear back"

  field :approved_at,    "card_account_opened_at"
  field :decline_reason, "card_account_decline_reason"

  def decline_reason_wrapper
    find("#" << decline_reason).find(:xpath, '..')
  end

  def set_approved_at_to(date)
    raise "error: approved at must be today or in the past" if date > Date.today

    set_datepicker_field("##{approved_at}", to: date)
  end
end
