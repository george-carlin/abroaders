require_relative "./card_account_on_page"

class AppliedCardAccountOnPage < CardAccountOnPage
  button :heard_back_and_approved, "My application was approved"
  button :heard_back_and_denied,   "My application was denied"
  button :nudged_and_approved, "My application was approved"
  button :nudged_and_denied,   "My application was denied"
  button :nudged_and_pending,  "I'm still waiting to hear back"
end
