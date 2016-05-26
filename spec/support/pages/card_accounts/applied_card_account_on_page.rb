require_relative "./card_account_on_page"

class AppliedCardAccountOnPage < CardAccountOnPage
  button :i_called,     "I called"
  button :i_heard_back, "The bank got back to me before I could call them"
  button :heard_back_and_approved, "My application was approved"
  button :heard_back_and_denied,   "My application was denied"
  button :nudged_and_approved, "My application was approved"
  button :nudged_and_denied,   "My application was denied"
  button :nudged_and_pending,  "I'm still waiting to hear back"
end
