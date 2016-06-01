require_relative "./card_account_on_page"

class NudgeableCardAccountOnPage < CardAccountOnPage
  button :approved,     "My application was approved"
  button :denied,       "My application was denied"
  button :pending,      "I'm still waiting to hear back"
  button :i_heard_back, "The bank got back to me before I could call them"
end
